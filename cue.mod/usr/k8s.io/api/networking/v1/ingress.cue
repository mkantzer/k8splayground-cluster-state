package v1

#Ingress: {
  apiVersion: "networking.k8s.io/v1"
	kind:       "Ingress"
  // metadata: {
  //   public: bool | *false
  //   ...
  // }
	spec: {
    ingressClassName: "alb"
    ...
	}
}