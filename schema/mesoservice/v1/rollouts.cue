package v1

import (
	"list"
	"strings"

	rollouts_v1alpha1 "github.com/argoproj/argo-rollouts/pkg/apis/rollouts/v1alpha1"
	dynamicinputs_v1 "github.com/mkantzer/k8splayground-cluster-state/schema/dynamicinputs/v1"
)

_#EasyPlatformEnvVars: [string]: string | {}

_#RolloutsOutput: [Context=string]: rollout: [Name=string]: rollouts_v1alpha1.#Rollout

_#RolloutsGenerator: {
	// Input for the caller
	X1=in:   #Input
	X2=tags: dynamicinputs_v1.#Tags

	// Output for the caller
	out: _#RolloutsOutput

	// Base rollout generation, without context-specific mutations
	_rolloutsBase: {
		for dsName, dsValue in X1.spec.deployedServices {
			let Name = "\(X1.metadata.name)-\(dsName)"
			let NonNameLabels = {
				for labelKey, labelValue in X1.metadata.labels if labelKey != "name" {
					"\(labelKey)": labelValue
				}
				X2.labels
			}

			"\(Name)": {
				apiVersion: "argoproj.io/v1alpha1"
				kind:       "Rollout"
				metadata: {
					name: Name
					labels: {
						name: Name
						NonNameLabels
					}
				}
				spec: {
					// Only set if we're in singleton mode:
					// Setting while an HPA is active causes thrashing.
					if dsValue.singleton {replicas: 1}
					revisionHistoryLimit: 10
					selector: matchLabels: {
						name: Name
						NonNameLabels
					}
					strategy: canary: {
						// // Prepopulating options for future reference.
						// // See generated file for field documentation, and to see which are optional.
						// // cue.mod/gen/github.com/argoproj/argo-rollouts/pkg/apis/rollouts/v1alpha1/types_go_gen.cue
						// // See Argo Rollouts docs for additional information:
						// // https://argo-rollouts.readthedocs.io/en/stable/features/canary/

						// // If `steps` is ommited, will mimic a Deployment's rolling update.
						// // https://argo-rollouts.readthedocs.io/en/stable/features/canary/#mimicking-rolling-update
						// steps: [...rollouts_v1alpha1.#CanaryStep]

						// canaryService: string
						// stableService: string
						// trafficRouting:              rollouts_v1alpha1.#RolloutTrafficRouting
						// maxUnavailable:              intstr.#IntOrString
						// maxSurge:                    intstr.#IntOrString
						// analyses:                    rollouts_v1alpha1.#RolloutAnalysisBackground
						// antiAffinity:                rollouts_v1alpha1.#antiAffinity
						// canaryMetadata:              rollouts_v1alpha1.#PodTemplateMetadata
						// stableMetadata:              rollouts_v1alpha1.#PodTemplateMetadata
						// scaleDownDelaySeconds:       int32
						// scaleDownDelayRevisionLimit: int32
						// abortScaleDownDelaySeconds:  int32
						// dynamicStableScale:          bool
						// pingPong:                    rollouts_v1alpha1.#PingPongSpec
						// minPodsPerReplicaSet:        int32
					}
					template: {
						metadata: labels: {
							name: Name
							NonNameLabels
						}
						spec: {
							// For now, all deployedServices in a given mesoservice share the same service account.
							serviceAccountName: "\(X1.metadata.name)-sa"
							containers: [{
								name: dsName
								// Manage setting separator correctly based on if ID is tag vs disgest.
								// https://github.com/kubernetes/website/blob/138209af9c6a1e1cd09ca76ed3e4d08019e528f3/content/en/docs/concepts/containers/images.md?plain=1#L94-L97
								if dsValue.imageTag != _|_ {
									image: "\(dsValue.imageName):\(dsValue.imageTag)"
								}
								if dsValue.imageDigest != _|_ {
									image: "\(dsValue.imageName)@\(dsValue.imageDigest)"
								}
								imagePullPolicy: "Always"
								env: {
									// Easier / more legible management of platform-provided variables.
									let EasyPlatformEnvVars = _#EasyPlatformEnvVars & {
										// Namespace the container is running in.
										// Used for routing to internal API endpoints.
										INTERNAL_API_BASE_URL: strings.Join([
													INTERNAL_API_BASE_SCHEME,
													INTERNAL_API_BASE_HOST,
													INTERNAL_API_BASE_PORT,
													INTERNAL_API_BASE_PATH,
										], "")
										INTERNAL_API_BASE_SCHEME: "http://"
										INTERNAL_API_BASE_HOST:   "\(X2.envSubdomain)main-gateway.internal"
										INTERNAL_API_BASE_PORT:   ":80"
										INTERNAL_API_BASE_PATH:   ""
										// Used for connecting to a managed Postgres instance for this mesoservice.
										let mesoserviceUpper = strings.ToUpper(X1.metadata.name)
										"PGSQL_\(mesoserviceUpper)_SCHEME": "postgresql://"
										"PGSQL_\(mesoserviceUpper)_HOST":   "\(X1.metadata.name).postgress.internal"
										"PGSQL_\(mesoserviceUpper)_PORT":   ":5432"
										"PGSQL_\(mesoserviceUpper)_PATH":   "/\(X1.metadata.name)"
									}
									list.Concat([[
										// Platform-defined values
										for k, v in EasyPlatformEnvVars {
											name: k
											// If v can unify with string w/o error, it's a string,
											// and therefor should be nested under `value:`
											if {v & string} != _|_ {value: v}

											// If it can't, it's a struct form, and therefor should
											// be inserted raw, as it's probably a `valueFrom:`
											if {v & string} == _|_ {v}
										}], [
										// User-defined values
										for k, v in dsValue.envVars {
											name: k
											value: {
												// If v can unify with string w/o error, it's a string
												if {v & string} != _|_ {v}

												// If it can't, it's the struct form.
												// You'd think the `default` value should be the "default",
												// but the preference mark actually ends up working the other way.
												if {v & string} == _|_ {*v[X2.envVarGroup] | v.default}
											}}],
									])
								}
								// https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits
								resources: {
									requests: {
										cpu:    "250m"
										memory: "1Gi"
									}
									limits: {
										cpu:    "500m"
										memory: "2Gi"
									}
								}
								ports: {[
									for k, v in dsValue.networking {
										name:          k
										protocol:      "TCP"
										containerPort: v.containerPort
									}]}
								if dsValue.probes.startup != _|_ {
									startupProbe: dsValue.probes.startup
								}
								if dsValue.probes.readiness != _|_ {
									readinessProbe: dsValue.probes.readiness
								}
								if dsValue.probes.liveness != _|_ {
									livenessProbe: dsValue.probes.liveness
								}
							}]}
					}
				}
			}
		}
	}

	// Set Outputs
	out: {
		prime: rollout: _rolloutsBase
	}
}
