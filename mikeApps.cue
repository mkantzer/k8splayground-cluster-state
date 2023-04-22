package kube

import (
	mikeApp_v1alpha1 "github.com/mkantzer/k8splayground-cluster-state/schema/mikeApp/v1alpha1"
)

// 
mikeApp: mikeApp_v1alpha1.#MikeApp // | 
  // mikeApp_v1alpha2.#MikeApp

mikeAppOutputs: mikeApp.outputs
