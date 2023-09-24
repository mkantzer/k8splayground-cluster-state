package kube

onboarding: "sample-app": {
	apiVersion: "v1"
	kind:       "Onboarding"
	metadata: labels: {
		repo: "SampleRepo"
		team: "teamname"
	}
	spec: prod: enabled: true
}
