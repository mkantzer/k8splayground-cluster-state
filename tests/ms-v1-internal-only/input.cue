package kube

inputTags: v1: {
	apiFirstLevelSubdomains:  "admin%api%apl%manager%member%public%www"
	envSubdomain:             ""
	useDnsPrefixesInternally: false
}

mesoservice: {
	apiVersion: "v1"
	metadata: {
		name: "ms-v1-networked"
		labels: {
			repo: "cluster-state"
			team: "Platform"
		}}
	spec: deployedServices: networked: {
		replicas:  3
		imageName: "ealen/echo-server"
		imageTag:  "0.5.1"
		networking: {
			public: {
				path:          "/v1/test"
				containerPort: 8080
				servicePort:   80
			}
			private: {
				path:          "/internal/test"
				containerPort: 9999
				servicePort:   9999
				internalOnly:  true
			}
		}
	}
}
