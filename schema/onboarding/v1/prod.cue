package v1

import (
	path_pkg "path"
	"strings"

	application_v1alpha1 "github.com/argoproj/argo-cd/v2/pkg/apis/application/v1alpha1"
)

// This file is responsible for generating the Application resource(s)
// to initialize the production deployment of the `prime` context.

// Handling of the list of clusters is not final: it's just an initial "good-enough".
// If we move to multiple production clusters, we will probably want to change this to an ApplicationSet,
// and use a Cluster Generator to dynamically target the prod culsters by label.

_#ProdClusterList: [clusterName=string]: {
	dnsSuffix:      string
	isActuallyProd: bool | *false
}

_prodClusterList: _#ProdClusterList & {
	"prod-cluster": {
		dnsSuffix:      "mk5r-prod.io"
		isActuallyProd: true
	}
	"mk5r-dev": dnsSuffix:  "mk5r-dev.io"
	"mk5r-dev2": dnsSuffix: "mk5r-dev2.io"
}

_#ProdOutput: application: [string]: application_v1alpha1.#Application

_#ProdGenerator: {
	// Input for the caller
	X1=in: #Input
	// Output for the caller
	out: _#ProdOutput

	// Intermediate fileds
	// Primary application generation
	// For field reference, see Argo's fully-utilized and commented example:
	// https://argo-cd.readthedocs.io/en/stable/operator-manual/application.yaml
	_prodApplications: {
		// Generate for each cluster in list where either:
		// - is not _actually_ production
		// - production is enabled.
		// The goal is to _always_ generate prodLikes for non-prod clusters, and only generate prod when enabled.
		for clusterName, clusterProps in _prodClusterList if (!clusterProps.isActuallyProd || X1.spec.prod.enabled) {
			let Name = "\(X1.metadata.name)-prod-\(clusterName)"
			let NonNameLabels = {
				for labelKey, labelValue in X1.metadata.labels if labelKey != "name" {
					"\(labelKey)": labelValue
				}
				mesoservice: X1.metadata.name
				context:     "prime"
				type:        "prod"
			}
			"\(Name)": {
				apiVersion: "argoproj.io/v1alpha1"
				kind:       "Application"
				metadata: {
					name: Name
					labels: {
						name: Name
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
						targetRevision: "HEAD"
						path:           path_pkg.Join([
								"mesoservices",
								X1.metadata.name,
						], path_pkg.Unix)
						plugin: {
							name: "cuelang-prime"
							env: [{
								name:  "DYNAMICTAGS"
								value: strings.Join([
									"-t apiFirstLevelSubdomains=api%input%www",
									"-t useDnsPrefixesInternally=false",
									"-t dnsExternalSuffix=\(clusterProps.dnsSuffix)",
									"-t envVarGroup=prodLike",
									"-t namespace=\(X1.metadata.name)",
								], " ")
							}]
						}
					}
					destination: {
						name:      clusterName
						namespace: X1.metadata.name
					}

					// Extra information to show in the Argo CD Application details tab
					// info: [{
					// 	name:  "Something"
					// 	value: "https://example.com"
					// }]

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
								name: X1.metadata.name
								NonNameLabels
								"gateway-access": "true"
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

					// ignoreDifferences: [{
					// 	// In case Cuelang starts changing the order of list renders, uncomment this block.
					// 	// The HPA controller will rearrange the order of metrics, so we want to be able to
					// 	// stop an infinate sync situation.
					// 	// https://github.com/argoproj/argo-cd/issues/1079#issuecomment-1369550159
					// 	group: "autoscaling"
					// 	kind:  "HorizontalPodAutoscaler"
					// 	jqPathExpressions: [
					// 		#".spec.metrics[].resource.name | select((. == "cpu") or (. == "memory"))"#,
					// 	]
					// }]
					revisionHistoryLimit: 10
				}
			}
		}
	}

	//set output
	out: application: _prodApplications
}
