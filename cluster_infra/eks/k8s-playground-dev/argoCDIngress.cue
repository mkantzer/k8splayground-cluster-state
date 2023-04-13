package kube

// ArgoCD Ingress Docs
// https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/

// AWS LB Ingress Controller Docs
// https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html

kubernetes: ingress: argoCD: {
	apiVersion: "networking.k8s.io/v1"
	metadata: {
		labels: {
			env: "playground-dev"
		}
	}
	// spec: {

	// }
}

// is it possible that all of this can get set up _by the helm chart_?
kubernetes: service: "argo-cd-argocd-server-grpc": {
	apiVersion: "v1"
	// kind: "Service"
	metadata: {
		annotations: {
			// Send traffic from the ALB using HTTP2. Can use GRPC as well if you want to leverage GRPC specific features
			"alb.ingress.kubernetes.io/backend-protocol-version": "HTTP2"
		}
		labels: {
			env: "playground-dev"
		}
	}
  spec: {
    ports: [{
      name: "443"
      port: 443
      protocol: "TCP"
      targetPort: 8080
    }]
    selector: "app.kubernetes.io/name": "argocd-server"
    sessionAffinity: "None"
    type: "NodePort"
  }
}
