package v1alpha1

// import (
//   	apps_v1 "k8s.io/api/apps/v1"
// )

#DeploymentsOutput: {
  // kubernetes: deployment: [string]: apps_v1.#Deployment
  #Spec
}

#DeploymentsTransform: {
  // Inputs for the caller
  metadata: #Metadata
  spec: #Spec

  // Output for the caller
  out: #DeploymentsOutput

  // intermediate fields
  for f in spec.fleet {
    _deployments: "\(metadata.name)-\(f.name)": {
      	metadata: labels: {
				repo: metadata.labels.repo
				team: metadata.labels.team
				env:  metadata.labels.env
			}
			spec: {
				replicas: f.replicas
				template: spec: containers: [{
					name:  f.name
					image: "\(f.imageName):\(f.imageTag)"
					env: [ for k, v in f.envVars {
						name:  k
						value: v
					}]
				}]
			}
    }
  }


  // set output
  // out: kubernetes: {
  //   deployment: _deployments
  // }
  out: spec
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