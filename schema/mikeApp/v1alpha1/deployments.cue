package v1alpha1

// import (
//   	apps_v1 "k8s.io/api/apps/v1"
// )

for f in mikeApp.spec.fleet {
  mikeApp: outputs: kubernetes: {
    deployment: "\(mikeApp.metadata.name)-\(f.name)" : {
      apiVersion: "apps/v1"
      kind: "Deployment"
      metadata: labels: {
        mikeApp.metadata.labels
      }
    }
  }
}