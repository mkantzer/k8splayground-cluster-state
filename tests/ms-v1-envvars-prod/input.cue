package kube

inputTags: v1: envVarGroup: "prodLike"

mesoservice: {
	apiVersion: "v1"
	metadata: {
		name: "ms-v1-envvars-prod"
		labels: {
			repo: "cluster-state"
			team: "Platform"
		}}
	spec: deployedServices: "basic-app": {
		replicas:    10
		imageName:   "ealen/echo-server"
		imageDigest: "sha256:2c94316d0dcb4602d510ca62eff06c9e760270d95e823212bfebb3cbcb480dfa"
		envVars: {
			TEST: "test"
			PORT: "8080"
			ENV_SPECIFIC_PREVIEW: {
				default: "default"
				preview: "devValue"
			}
			ENV_SPECIFIC_PRODLIKE: {
				default:  "default"
				prodLike: "prodValue"
			}
			ENV_SPECIFIC_NEITHER: default: "default"
		}
	}
}
