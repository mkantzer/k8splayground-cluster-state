package v1alpha1

import (
	apps_v1 "k8s.io/api/apps/v1"
)

_#DeploymentsOutput: deployment: [string]: apps_v1.#Deployment

_#DeploymentsGenerator: {
	// Input for the caller
	X1="in": #Input
	// Output for the caller
	out: _#DeploymentsOutput

	// Intermediate fields
	// Primary deployment generation
	_deployments: {
		for k, v in X1.spec.fleet {
			let Name = "\(X1.metadata.name)-\(k)"
			let NonNameLabels = {for k, v in X1.metadata.labels if k != "name" {"\(k)": v}}
			"\(Name)": {
				apiVersion: "apps/v1"
				kind:       "Deployment"
				metadata: {
					name: Name
					labels: {
						name: Name
						NonNameLabels
					}
				}
				spec: {
					replicas:             v.replicas
					minReadySeconds:      10
					revisionHistoryLimit: 10
					selector: matchLabels: {
						name: Name
						NonNameLabels
					}
					template: {
						metadata: labels: {
							name: Name
							NonNameLabels
						}
						spec: containers: [{
							name:            k
							image:           "\(v.imageName):\(v.imageTag)"
							imagePullPolicy: "IfNotPresent"
							env: {[
								for n, c in v.envVars {
									name:  n
									value: c
								}]
							}
						}]
					}
				}
			}
		}
	}

	// Set output
	out: {
		deployment: _deployments
	}
}
