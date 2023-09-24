package kube

onboarding: auth: {
	apiVersion: "v1"
	kind:       "Onboarding"
	metadata: labels: {
		repo: "auth-service"
		team: "auth"
	}
	spec: prod: enabled: true
}
