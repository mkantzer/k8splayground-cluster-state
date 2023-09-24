package kube

onboarding: cart: {
	apiVersion: "v1"
	kind:       "Onboarding"
	metadata: labels: {
		repo: "cart-service"
		team: "cart"
	}
	spec: prod: enabled: true
}
