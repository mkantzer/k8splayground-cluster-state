package kube

mesoservice: {
	apiVersion: "v1"
	metadata: {
		name: "ms-v1-singleton"
		labels: {
			repo: "cluster-state"
			team: "Platform"
		}}
	spec: deployedServices: "basic-app": {
		singleton:   true
		imageName:   "ealen/echo-server"
		imageDigest: "sha256:2c94316d0dcb4602d510ca62eff06c9e760270d95e823212bfebb3cbcb480dfa"
	}
}
