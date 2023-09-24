package kube

kubernetes: namespace: echo: {
	metadata: {
		labels: {
			env: "dev"
		}
	}
}
