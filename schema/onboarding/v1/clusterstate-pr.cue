package v1

import (
	path_pkg "path"
	"strings"

	application_v1alpha1 "github.com/argoproj/argo-cd/v2/pkg/apis/application/v1alpha1"
)

// This file is responsible for generating the ApplicationSet resource(s) used for testing
// pull requests made to the Tenants repo. It uses a Pull Request generator to target all PRs in `k8splayground-cluster-state`.
// The generators also optionally filter based on labels, for deploying to clusters in addition to `cicd1`.

// The result of this, is that for each PR to tenants, an `Application` is generated for each onboarded
// mesoservice, which are torn down when the PR is closed or merged. We're doing this via an ApplicationSet
// for each mesoservice instead of a single one with an added List generator matrixed with the PR generator,
// because `onboard` is called on a per-mesoservice basis, to allow each team to version their usage
// independantly. As such, we don't have access to the full top-level `onboarding:` object within this package.

// For now, we are only creating Applications to render the `prime` context.
// We might add some other renders in the future, if we find we need it for testing things like
// workflows or cloudresources.

_#DevClusterList: [clusterName=string]: {
	dnsSuffix:  string
	shortName:  string | *clusterName
	requireTag: bool | *false // if false, receives _all_ prs.
}

_devClusterList: _#DevClusterList & {
	"mk5r-dev": {
		shortName: "dev"
		dnsSuffix: "mk5r-dev.io"
	}
	"mk5r-dev2": {
		shortName:  "dev2"
		dnsSuffix:  "mk5r-dev2.io"
		requireTag: true
	}
}

_#CSPROutput: applicationset: [string]: application_v1alpha1.#ApplicationSet

_#CSPRGenerator: {
	// Input for the caller
	X1=in: #Input
	// Output for the caller
	out: _#CSPROutput

	// Intermediate fileds
	// Primary applicationset generation
	// For field reference, see Argo's example:
	// https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset.yaml
	// and their general guide: https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/
	_tenantsPRApplicationSets: {
		for clusterName, clusterProps in _devClusterList {

			let Name = "\(X1.metadata.name)-cspr-\(clusterProps.shortName)-prime"
			let NonNameLabels = {
				for labelKey, labelValue in X1.metadata.labels if labelKey != "name" {
					"\(labelKey)": labelValue
				}
				mesoservice: X1.metadata.name
				context:     "prime"
				type:        "clusterstate-pr"
			}
			"\(Name)": {
				apiVersion: "argoproj.io/v1alpha1"
				kind:       "ApplicationSet"
				metadata: {
					name: Name
					labels: {
						name: Name
						NonNameLabels
					}}
				spec: {
					generators: [{
						pullRequest: {
							github: {
								owner:         "mkantzer"
								repo:          "k8splayground-cluster-state"
								appSecretName: "argocd-repo-creds-gh-mk5r-app"
								if clusterProps.requireTag {
									labels: [clusterName]
								}
							}
							requeueAfterSeconds: 15 // Setting this low, until we get the webhook working correctly (It's currently 503ing for some reason). The default is every 30min.
						}}]
					template: {
						metadata: {
							name: "\(Name)-{{number}}"
							labels: {
								name:            "\(Name)-{{number}}"
								pullrequestid:   "{{number}}"
								pullrequestrepo: "k8splayground-cluster-state"
								NonNameLabels
							}
							finalizers: [
								"resources-finalizer.argocd.argoproj.io",
							]
						}
						spec: {
							project: "root"
							source: {
								repoURL:        "git@github.com:LeagueApps/tenants.git"
								targetRevision: "{{branch}}"
								path:           path_pkg.Join([
										"mesoservices",
										X1.metadata.name,
								], path_pkg.Unix)
								plugin: {
									name: "cuelang-prime"
									env: [{
										name:  "DYNAMICTAGS"
										value: strings.Join([
											// Can't nest subdomains: wildcard certs only support a single level.
											// If we ever get dynamic cert creation, we may be able to change that.
											"-t apiFirstLevelSubdomains=api",
											"-t envSubdomain={{number}}-cspr.",
											"-t useDnsPrefixesInternally=true",
											"-t dnsExternalSuffix=\(clusterProps.dnsSuffix)",
											"-t envVarGroup=preview",
											"-t namespace=\(X1.metadata.name)-tntspr-{{number}}",
										], " ")
									}]
								}
							}
							destination: {
								name:      "\(clusterName)"
								namespace: "\(X1.metadata.name)-cspr-{{number}}"
							}

							syncPolicy: {
								automated: {
									prune:      true
									selfHeal:   true
									allowEmpty: false
								}
								syncOptions: [
									"Validate=true",
									"CreateNamespace=true",
									"PrunePropagationPolicy=foreground",
									"PruneLast=true",
								]
								managedNamespaceMetadata: {
									labels: {
										name: "\(X1.metadata.name)-cspr-{{number}}"
										NonNameLabels
										"gateway-access": "true"

										// Will be used by nscleanup_tool to identify candidate Namespaces.
										// Not used at time of initial introduction of tool, because orphaned namespaces wouldn't have these tags.
										// By adding them _now_, we can ensure that in the future, we can more easily sort them.
										"ephemeral-ns":  "true"
										pullrequestrepo: "k8splayground-cluster-state"
										pullrequestid:   "{{number}}"
									}
									// annotations: {}
								}
								retry: {
									limit: 5
									backoff: {
										duration:    "5s"
										factor:      2
										maxDuration: "3m"
									}
								}
							}
							revisionHistoryLimit: 10
						}
					}
				}
			}
		}
	}

	// set output
	out: applicationset: _tenantsPRApplicationSets
}
