package kube

// If we wanted to, we could test out some tags here
inputTags: v1: {...}

mesoservice: {
	apiVersion: "v1"
	metadata: {
		name: "ms-v1-basic-app"
		labels: {
			repo: "cluster-state"
			team: "Platform"
		}}
	spec: deployedServices: "basic-app": {
		replicas:    3
		imageName:   "ealen/echo-server"
		imageDigest: "sha256:2c94316d0dcb4602d510ca62eff06c9e760270d95e823212bfebb3cbcb480dfa"
		envVars: {
			TEST: "test"
			PORT: "8080"
		}
		metrics: {
			path: "metrics/"
			port: "8080"
		}
		probes: {
			[string]: {
				initialDelaySeconds: 5
				timeoutSeconds:      3
				httpGet: port: 8080
			}
			startup: httpGet: path:   "/probe/startup"
			readiness: httpGet: path: "/probe/ready"
			// liveness: httpGet: path:  "probe/live"
		}
		networking: {
			primary: {
				containerPort: 8080
				servicePort:   80
			}
			secondary: {
				containerPort: 9999
				servicePort:   9999
			}
		}
	}
}
