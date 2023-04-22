package kube

import (
	mikeApp_v1alpha1 "github.com/mkantzer/k8splayground-cluster-state/schema/mikeApp/v1alpha1"
)

// Primary Declaration
// mikeApp: mikeApp_v1alpha1.#MikeApp // | mikeApp_v1alpha2.#MikeApp
mikeApp?: mikeApp_v1alpha1.mikeApp // | mikeApp_v1alpha2.#MikeApp

// Example of accessing output.
mikeAppOutputs: mikeApp.outputs // <- process into k8s objects?
