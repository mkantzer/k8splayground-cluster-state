package kube

kubernetes: ingress: echo: {
	metadata: {
		namespace: "echo"
		labels: env: "dev"
		annotations: {
			"alb.ingress.kubernetes.io/scheme":       "internet-facing"
			"alb.ingress.kubernetes.io/listen-ports": "[{\"HTTPS\":443}]"
			"alb.ingress.kubernetes.io/target-type":  "ip"
		}
	}
	spec: {
		rules: [{
			host: "dev.clusters.kantzer.io"
			http: paths: [{
				path:     "/echo"
				pathType: "Prefix"
				backend: service: {
					name: "echo"
					port: number: 80
				}
			}]
		}]
	}
}
