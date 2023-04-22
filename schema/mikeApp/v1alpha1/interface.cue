package v1alpha1

// This file houses the primary definitions for the external-facing
// components of this package.

// Input values are processed in other files, and then collected here into
// the final output object.


testValues: "lol"

#example: {
  input: string
  output: input
}

// Primary Schema Definition:
#MikeApp: {
   apiVersion: "v1alpha1"
   kind: "MikeApp"
   metadata: {
    name: string
    labels: [string]: string
    labels: {
      name: metadata.name // Should I define this elsewhere?
      repo: string
      team: string
      env: "local" | "dev" | "production"
      ...
    }
   }
  //  spec: {
  //   // `fleet` represents the persistent processors of the application.
  //   // This can be thought of as an abstraction above a "deployment", where pods are
  //   // expected to always be available. This is in contrast to `jobs`, which are expected
  //   // to exit with success once finished.
  //   fleet: [Name=_]: {
  //     name: Name
  //     replicas: *3 | int
  //     imageName: "mkantzer/\(metadata.name)/\(Name)"
  //     imageTag: string | *"latest" // probably shouldn't default to latest
  //     envVars: [Key=_]: string // user-defined vars
  //     // networking: [PortName=_]: {
  //     //   ingress?: {
  //     //     public: bool | *false
  //     //     externalPort: int
  //     //     externalPath: string | *"/"
  //     //     internalPath: string | *"/"
  //     //   }
  //     // }
  //   }
  //  }
   outputs: {
    examples: {
      name: metadata.name
    }
   }
}