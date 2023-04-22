package v1alpha1

import (
  	apps_v1 "k8s.io/api/apps/v1"
)

_#DeploymentsOutput: {
  kubernetes: deployment: [string]: apps_v1.#Deployment
}

_#DeploymentsTransform: {
  // Inputs for the caller
  metadata: _#Metadata
  spec: _#Spec

  // Output for the caller
  out: _#DeploymentsOutput

  // intermediate fields
  



  // set output
  // out: kubernetes: deployment: 
}












// #MikeApp: outputs: kubernetes: deployment: {
//   for f in mikeApp.spec.fleet {
//     "\(mikeApp.metadata.name)-\(f.name)": {
//       test: "yes"
//     }
//   }
// }

// for f in #MikeApp.spec.fleet {
//   kubernetes: {
//     deployment: "\(mikeApp.metadata.name)-\(f.name)" : {
//       apiVersion: "apps/v1"
//       kind: "Deployment"
//       metadata: labels: {
//         mikeApp.metadata.labels
//       }
//     }
//   }
// }


// _#Deployments: {
//   input: {
//     metadata: _#Metadata
//     spec: _#Spec
//   }
//   output: {
//     for f in input.spec.fleet {
//       test: "lol"
//     }
//   }
// }