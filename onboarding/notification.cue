package kube

onboarding: notification: {
	apiVersion: "v1"
	kind:       "Onboarding"
	metadata: labels: {
		repo: "notification-service"
		team: "cart"
	}
	spec: prod: enabled: false
}
