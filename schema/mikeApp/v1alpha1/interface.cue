package v1alpha1

#Metadata: {
	name: string
	labels: [string]: string
}

#Spec: {
	fleet: [string]: #Fleet
}

#Fleet: {
	name:      string
	replicas:  int
	imageName: string
	imageTag:  string
	envVars: [string]: string
}

#App: {
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
		fleet: [Name=_]: #Fleet & {
			name:      Name
			replicas:  int | *3
			imageName: string | *"mkantzer/\(metadata.name)/\(Name)"
			imageTag:  string | *"latest" // probably shouldn't default to latest
			envVars: [string]: string // user-defined vars
		}
	}
}

#Input: {
	metadata: #Metadata
	spec:     #Spec
}

#Output: {
	kubernetes: [string]: {...}
}

#Generator: {
	// Input for the caller
	X1="in": #Input
	// Output for the caller
	out: #Output

	//intermediate fields
	_deployments: _#DeploymentsGenerator & {in: X1}

	// set output
	out: {
		// generated deployments
		kubernetes: _deployments.out
		// kubernetes: _services.out
	}
}
