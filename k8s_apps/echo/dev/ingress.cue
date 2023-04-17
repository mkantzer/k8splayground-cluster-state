package kube

import "encoding/json"

kubernetes: ingress: echo: {
	metadata: {
		namespace: "echo"
		labels: env: "dev"
		annotations: {
			"alb.ingress.kubernetes.io/scheme":               "internet-facing"
			"alb.ingress.kubernetes.io/target-type":          "ip"
			"alb.ingress.kubernetes.io/listen-ports":         "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
			"alb.ingress.kubernetes.io/actions.ssl-redirect": json.Marshal({
				Type: "redirect"
				RedirectConfig: {
					Protocol:   "HTTPS"
					Port:       "443"
					StatusCode: "HTTP_301"
				}
			})
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
