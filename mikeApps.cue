package kube

import (
	mikeApp_v1alpha1 "github.com/mkantzer/k8splayground-cluster-state/schema/mikeApp/v1alpha1"
)

// Format validation
mikeApp: mikeApp_v1alpha1.#App // | mikeApp_v1alpha2.#App

// Initialize field, so it can be referenced outside the `if` scopes
appGenerator: {}

// Call functions based on versions
if mikeApp.apiVersion == "v1alpha1" {
	appGenerator: mikeApp_v1alpha1.#Generator & {in: {
		metadata: mikeApp.metadata
		spec:     mikeApp.spec
	}}
}

// Handle output
kubernetes: {
	appGenerator.out.kubernetes
	...
}
