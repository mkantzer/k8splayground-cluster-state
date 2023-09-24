package kube

kubernetes: service: echo: {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		labels: {
			name: "echo"
			env:  "dev"
		}
		name:      "echo"
		namespace: "echo"
	}
	spec: {
		ports: [{
			name:       "echo-api"
			port:       80
			targetPort: 80
		}]
		selector: name: "echo"
	}
}
