package kube

import (
	mikeApp_v1alpha1 "github.com/mkantzer/k8splayground-cluster-state/schema/mikeApp/v1alpha1:v1alpha1"
)

// Primary Declaration
// mikeApp: mikeApp_v1alpha1.#MikeApp // | mikeApp_v1alpha2.#MikeApp
mikeApp?: mikeApp_v1alpha1.#MikeApp // | mikeApp_v1alpha2.#MikeApp

// Example of accessing output.
mikeAppOutputs: mikeApp.outputs // <- process into k8s objects?

// for f in mikeApp.spec.fleet {
//     "\(mikeApp.metadata.name)-\(f.name)": {
//       test: "yes"
//     }
// }
