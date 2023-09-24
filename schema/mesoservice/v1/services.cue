package v1

import (
	core_v1 "k8s.io/api/core/v1"
	dynamicinputs_v1 "github.com/mkantzer/k8splayground-cluster-state/schema/dynamicinputs/v1"
)

_#ServicesOutput: [Context=string]: service: [string]: core_v1.#Service

_#ServicesGenerator: {
	// Input for the caller
	X1=in:   #Input
	X2=tags: dynamicinputs_v1.#Tags
	// Output for the caller
	out: _#ServicesOutput

	// Intermediate fields
	// Base services generation, without context-specific mutations
	_servicesBase: {
		for dsName, dsValue in X1.spec.deployedServices {
			let Name = "\(X1.metadata.name)-\(dsName)"
			let NonNameLabels = {
				for labelKey, labelValue in X1.metadata.labels if labelKey != "name" {
					"\(labelKey)": labelValue
				}
				X2.labels
			}

			for networkName, networkValue in dsValue.networking {
				let FullName = "\(Name)-\(networkName)"
				"\(FullName)": {
					apiVersion: "v1"
					kind:       "Service"
					metadata: {
						name: FullName
						labels: {
							name: FullName
							NonNameLabels
						}
					}
					spec: {
						selector: {
							// intentionally _not_ FullName: we want to match the deployment
							name: Name
							NonNameLabels
						}
						ports: [{
							name:       networkName
							port:       networkValue.servicePort
							targetPort: networkValue.containerPort
						}]
					}
				}
			}
		}
	}

	// Set Outputs
	out: {
		prime: service: _servicesBase
	}
}
