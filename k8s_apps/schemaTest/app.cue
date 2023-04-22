package kube

mikeApp: {
	metadata: {
		name: "schemaTest"
		labels: {
			repo: "mkantzer/some-test-app"
			team: "JustMe"
		}}
	spec: {
		fleet: {
			echo: {
				replicas:  2
				imageName: "ealen/echo-server"
				imageTag:  "0.5.1"
				envVars: {
					PORT:                "80"
					ENABLE__COOKIES:     "false"
					ENABLE__ENVIRONMENT: "false"
				}
			}
		}
	}
}
