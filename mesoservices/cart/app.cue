package kube

mesoservice: {
	apiVersion: "v1"
	metadata: {
		name: "cart"
		labels: {
			repo: "cart-service"
			team: "cart"
		}}
	spec: deployedServices: echo: {
		replicas:  3
		imageName: "docker.io/ealen/echo-server"
		imageTag:  "0.8.6"
		envVars: PORT: "1400"
		metrics: {
			path: "/q/metrics"
			port: 1400
		}
		probes: {
			readiness: httpGet: {
				path: "/q/health/ready"
				port: 1400
			}
			liveness: httpGet: {
				path: "/q/health/live"
				port: 1400
			}
		}
		networking: http: {
			path:          "/api/cart"
			containerPort: 1400
			servicePort:   80
		}
	}
}
