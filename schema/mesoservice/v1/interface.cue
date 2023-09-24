package v1

import (
	dynamicinputs_v1 "github.com/mkantzer/k8s-playground-cluster-state/schema/dynamicinputs/v1"
	"k8s.io/apimachinery/pkg/util/intstr"
)

// External-facing Mesoservice spec. Not used for input, but _is_ used for structure enforcement.
#Mesoservice: {
	apiVersion: "v1"
	kind:       "mesoservice"
	metadata:   _#Metadata
	spec:       _#Spec
}

// *******************************************
// Primary function-like interface
// *******************************************

// Main user-facing inputs
#Input: {
	metadata: _#Metadata
	spec:     _#Spec
}

#Output: kubernetes: [Context=string]: [Kind=string]: [Name=string]: {...}

#Generator: {
	// Input for the caller
	X1=in:   #Input
	X2=tags: dynamicinputs_v1.#Tags
	// Output for the caller
	out: #Output

	//intermediate fields
	// _deployments:         _#DeploymentsGenerator & {in:         X1, tags: X2}
	_rollouts:                 _#RolloutsGenerator & {in:                 X1, tags: X2}
	_services:                 _#ServicesGenerator & {in:                 X1, tags: X2}
	_podmonitors:              _#PodMonitorsGenerator & {in:              X1, tags: X2}
	_httproutes:               _#HTTPRoutesGenerator & {in:               X1, tags: X2}
	_serviceaccounts:          _#ServiceAccountsGenerator & {in:          X1, tags: X2}
	_horizontalpodautoscalers: _#HorizontalPodAutoscalersGenerator & {in: X1, tags: X2}

	// set output
	out: {
		// generated manifests
		kubernetes: {
			for context in [ "prime"] {
				"\(context)": {
					// _deployments.out["\(context)"]
					_rollouts.out["\(context)"]
					_services.out["\(context)"]
					_httproutes.out["\(context)"]
					_podmonitors.out["\(context)"]
					_serviceaccounts.out["\(context)"]
					_horizontalpodautoscalers.out["\(context)"]
				}
			}
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
#Mesoservice: metadata: {
	name: string
	labels: name:        metadata.name
	labels: mesoservice: metadata.name
	...
}

_#Spec: deployedServices: [string]: _#DeployedService

_#DeployedService: {
	singleton: bool | *false // overwrites "normal" scaling and replicas. For legacy components only.
	replicas:  int & >=3 | *3
	imageName: string
	// Only allow setting a tag OR a digest: https://cuetorials.com/patterns/fields/#oneof
	let #ImageIdentifier = {imageTag: string & !="latest"} | {imageDigest: string}
	#ImageIdentifier
	metrics?: _#Metrics
	probes?: {
		startup?:   _#Probe
		readiness?: _#Probe
		liveness?:  _#Probe
	}
	envVars: [string]:    _#EnvVarValue
	networking: [string]: _#Networking
}

_#EnvVarValue: string | {
	default:   string
	prodLike?: string
	preview?:  string
}

_#Networking: {
	path?:         =~"^/.*[^/]$" // sets path for HTTPRoute resource. Must start with `/`, must never end with `/`.
	servicePort:   int | *80     // Port that clients should address
	containerPort: int | *80     // Port the pod is listening on
	internalOnly:  bool | *false // Whether or not to attach to the external gateway
}

_#Probe: {
	initialDelaySeconds: int | *2
	timeoutSeconds:      int | *10
	httpGet: {
		path: string | *"/"
		port: int | *80
	}
}

_#Metrics: {
	path: string | *"/metrics"
	port: intstr.#IntOrString | *80
}
