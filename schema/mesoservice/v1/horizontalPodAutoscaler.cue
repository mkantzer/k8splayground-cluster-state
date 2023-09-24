package v1

import (
	autoscaling_v2 "k8s.io/api/autoscaling/v2"
	dynamicinputs_v1 "github.com/mkantzer/k8splayground-cluster-state/schema/dynamicinputs/v1"
)

_#HorizontalPodAutoscalersOutput: [Context=string]: horizontalpodautoscaler: [Name=string]: autoscaling_v2.#HorizontalPodAutoscaler

_#HorizontalPodAutoscalersGenerator: {
	// Input for the caller
	X1=in:   #Input
	X2=tags: dynamicinputs_v1.#Tags
	// Output for the caller
	out: _#HorizontalPodAutoscalersOutput

	// Base generator, without context-specific mutations
	_horizontalPodAutoscalersBase: {
		for dsName, dsValue in X1.spec.deployedServices {
			// Don't create an HPA for singleton components
			if !dsValue.singleton {
				let Name = "\(X1.metadata.name)-\(dsName)"
				let NonNameLabels = {
					for labelKey, labelValue in X1.metadata.labels if labelKey != "name" {
						"\(labelKey)": labelValue
					}
					X2.labels
				}

				(Name): {
					apiVersion: "autoscaling/v2"
					kind:       "HorizontalPodAutoscaler"
					metadata: {
						name: Name
						labels: {
							name: Name
							NonNameLabels
						}
					}
					spec: {
						scaleTargetRef: {
							apiVersion: "argoproj.io/v1alpha1"
							kind:       "Rollout"
							name:       Name
						}
						minReplicas: dsValue.replicas
						maxReplicas: dsValue.replicas * 10 // At most, allow 10fold increase.
						metrics: [{
							type: "Resource"
							resource: {
								name: "memory"
								target: {
									type:               "Utilization"
									averageUtilization: 75
								}
							}
						}, {
							type: "Resource"
							resource: {
								name: "cpu"
								target: {
									type:               "Utilization"
									averageUtilization: 75
								}
							}
						}]
					}
				}
			}
		}
	}

	// Set Outputs
	out: {
		prime: horizontalpodautoscaler: _horizontalPodAutoscalersBase
	}
}
