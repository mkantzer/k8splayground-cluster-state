package v1alpha1

// This file houses the primary definitions for the external-facing components.

// Input values are processed in other files, and then collected here into
// the final output object.

// #example: {
// 	input:  string
// 	output: input
// }

// Internal object init, for use within package
// mikeApp: #MikeApp

#Metadata: {
	name: string
	labels: [string]: string
}

#Spec: {
	fleet: [string]: #Fleet
}

// `fleet` represents the persistent processors of the application.
// This can be thought of as an abstraction above a "deployment", where pods are
// expected to always be available.
// This is in contrast to `jobs`, which are expected to exit with success once finished.
#Fleet: {
	name:      string
	replicas:  int
	imageName: string
	imageTag:  string
	envVars: [string]: string
}

// Primary Schema Definition:
#MikeApp: {
	apiVersion: "v1alpha1"
	kind:       "MikeApp"
	metadata:   #Metadata & {
		name: string
		labels: {
			name: metadata.name // Should I define this elsewhere?
			repo: string
			team: string
			env:  "local" | "dev" | "production"
			...
		}
	}
	spec: #Spec & {
		fleet: [Name=_]: {
			name:      Name // should I define this elsewhere?
			replicas:  int | *3
			imageName: string | *"mkantzer/\(metadata.name)/\(Name)"
			imageTag:  string | *"latest" // probably shouldn't default to latest
			envVars: [string]: string // user-defined vars

			// networking: [PortName=_]: {
			//   ingress?: {
			//     public: bool | *false
			//     externalPort: int
			//     externalPath: string | *"/"
			//     internalPath: string | *"/"
			//   }
			// }
		}
	}
	outputs: {
		// spec
		result: #DeploymentsTransform & {metadata: metadata, spec: spec}

		// kubernetes: {...}
		...
	}
}
