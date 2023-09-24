package kube

onboarding: "demo-simple-cue": {
	apiVersion: "v1"
	kind:       "Onboarding"
	metadata: labels: {
		repo: "cluster-state"
		team: "Platform"
	}
	spec: prod: enabled: true
}
