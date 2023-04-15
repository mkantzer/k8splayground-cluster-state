package kube

kubernetes: deployment: echo: {
	metadata: {
		namespace: "echo"
		labels: {
			env: "dev"
		}
	}
	spec: {
		minReadySeconds:      10
		replicas:             2
		revisionHistoryLimit: 10
		selector: matchLabels: name: "echo"
		template: {
			metadata: labels: name: "echo"
			spec: containers: [{
				env: [{
					name:  "PORT"
					value: "80"
				}]
				image:           "ealen/echo-server:0.5.1"
				imagePullPolicy: "IfNotPresent"
				name:            "echo"
				ports: [{
					containerPort: 80
					name:          "api"
				}]
			}]
		}
	}
}
