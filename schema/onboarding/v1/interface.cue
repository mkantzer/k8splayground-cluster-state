package v1

// External-facing Onboarding spec. Not used for input, but _is_ used for structure enforcement.
#Onboarding: {
	apiVersion: "v1"
	kind:       "Onboarding"
	metadata:   _#Metadata
	spec:       _#Spec
}

// *******************************************
// Primary function-like interface
// *******************************************

#Input: {
	metadata: _#Metadata
	spec:     _#Spec
}

#Output: kubernetes: [string]: {...}

#Generator: {
	// Input for the caller
	X1=in: #Input
	// Output for the caller
	out: #Output

	//intermediate fields
	_prodApplications:              _#ProdGenerator & {in:           X1}
	_clusterStatePRApplicationSets: _#ClusterStatePRGenerator & {in: X1}

	// set output
	out: {
		// generated manifests
		kubernetes: {
			_prodApplications.out
			_clusterStatePRApplicationSets.out
		}
	}
}

// *******************************************
// Intermediate spec definitions.
// These _probably_ don't need to be exported.
// *******************************************

_#Metadata: {
	name: string
	labels: [string]: string
	labels: {
		name: string & =~"^[a-z0-9]([-a-z0-9]*[a-z0-9])?$" & _#Metadata.name
		repo: string
		team: string
		...
	}
}

// small helper
#Onboarding: metadata: {
	name: string
	labels: name: metadata.name
	...
}

_#Spec: prod: enabled: bool | *false
