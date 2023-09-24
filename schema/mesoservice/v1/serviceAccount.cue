package v1

import (
	core_v1 "k8s.io/api/core/v1"
	dynamicinputs_v1 "github.com/mkantzer/k8s-playground-cluster-state/schema/dynamicinputs/v1"
)

_#ServiceAccountsOutput: [Context=string]: serviceaccount: [string]: core_v1.#ServiceAccount

_#ServiceAccountsGenerator: {
	// Input for the caller
	X1=in:   #Input
	X2=tags: dynamicinputs_v1.#Tags
	// Output for the caller
	out: _#ServiceAccountsOutput

	// Intermediate fields
	// Base serviceaccount generation, without context-specific mutations
	// (For now), all deployedServices in a mesoservice will use the same ServiceAccount.
	_serviceaccountsBase: {
		// Don't create anything if there aren't any deployedServices
		if len(X1.spec.deployedServices) > 0 {

			let Name = "\(X1.metadata.name)-sa"
			let NonNameLabels = {
				for labelKey, labelValue in X1.metadata.labels if labelKey != "name" {
					"\(labelKey)": labelValue
				}
				X2.labels
			}

			"\(Name)": {
				apiVersion: "v1"
				kind:       "ServiceAccount"
				metadata: {
					name: Name
					labels: {
						name: Name
						NonNameLabels
					}
					// Put any needed annotations here, especially those used to link a k8s SA to
					// a cloud provider SA.
					annotations: {...}
				}
			}
		}
	}

	// Set Outputs
	out: {
		prime: serviceaccount: _serviceaccountsBase
	}
}
