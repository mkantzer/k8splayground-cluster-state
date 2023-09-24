package v1

import (
	"strings"
	"list"

	gateway_v1beta1 "sigs.k8s.io/gateway-api/apis/v1beta1"
	dynamicinputs_v1 "github.com/mkantzer/k8s-playground-cluster-state/schema/dynamicinputs/v1"
)

_#HTTPRoutesOutput: [Context=string]: httproute: [string]: gateway_v1beta1.#HTTPRoute

_#HTTPRoutesGenerator: {
	// Input for the caller
	X1=in:   #Input
	X2=tags: dynamicinputs_v1.#Tags
	// Output for the caller
	out: _#HTTPRoutesOutput

	// Base httproutes generation, without context-specific mutations

	_httproutesBase: {
		for dsName, dsValue in X1.spec.deployedServices {
			let Name = "\(X1.metadata.name)-\(dsName)"
			let NonNameLabels = {
				for labelKey, labelValue in X1.metadata.labels if labelKey != "name" {
					"\(labelKey)": labelValue
				}
				X2.labels
			}

			for networkName, networkValue in dsValue.networking if networkValue.path != _|_ {
				let FullName = "\(Name)-\(networkName)-internal"
				"\(FullName)": {
					apiVersion: "gateway.networking.k8s.io/v1beta1"
					kind:       "HTTPRoute"
					metadata: {
						name: FullName
						labels: {
							name: FullName
							NonNameLabels
						}
					}
					spec: {
						parentRefs: [{
							name:        "internal-gateway"
							namespace:   "gateways"
							sectionName: "http"
						}]
						hostnames: list.Concat([
								[ for sd in X2.apiFirstLevelSubdomainsActual {
								// Also, we may end up with many of the same entry, but that's okay.
								"\(X2.envSubdomain)main-gateway.internal"
							}], [
								if X2.envSubdomain == "" {
									"*.main-gateway.internal"
								},
							],
						])
						rules: [{
							matches: [{
								path: {
									type:  "PathPrefix"
									value: networkValue.path
								}
							}]
							backendRefs: [{
								name: strings.TrimSuffix(FullName, "-internal")
								port: networkValue.servicePort
							}]
						}]
					}
				}
			}
		}
	}

	// Set Outputs
	out: {
		prime: httproute: _httproutesBase
	}
}
