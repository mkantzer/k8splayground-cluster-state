package kube

inputTags: v1: {
	apiFirstLevelSubdomains:  "api"
	envSubdomain:             "dummy-repo-pr."
	useDnsPrefixesInternally: true
}

mesoservice: {
	apiVersion: "v1"
	metadata: {
		name: "ms-v1-networked"
		labels: {
			repo: "cluster-state"
			team: "Platform"
		}}
	spec: deployedServices: {
		networked: {
			replicas:  3
			imageName: "ealen/echo-server"
			imageTag:  "0.5.1"
			networking: {
				gatewayed: {
					path:          "/v1/test"
					containerPort: 8080
					servicePort:   80
				}
				nongatewayd: {
					containerPort: 9999
					servicePort:   9999
				}
			}
		}
		"non-networked": {
			replicas:  3
			imageName: "ealen/echo-server"
			imageTag:  "0.5.1"
		}
	}
}
