package v1

#Deployment: {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	spec: {
		replicas: *1 | int
		// template: {
		// 	metadata: labels: {
		// 		...
		// 	}
		// }
	}
}
