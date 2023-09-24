package kube

// Use of the abstraction schema
mesoservice: {
	apiVersion: "v1"
	metadata: {
		name: "demo-mesoservice"
		labels: {
			repo: "cluster-state"
			team: "Platform"
		}}
	spec: deployedServices: echo: {
		replicas:  3
		imageName: "docker.io/ealen/echo-server"
		imageTag:  "0.8.6"
		envVars: {
			PORT:                    "80"
			ENABLE_ROOT_PATH:        "false"
			ENABLE_HEALTHCHECK_LOGS: "false"
		}
		metrics: {
			path: "/metrics"
			port: "http"
		}
		probes: readiness: httpGet: path: "/health-check"
		networking: http: path: "/api/echo/v1"
	}
}
