package v1

import (
	"strings"
	"list"

	dynamicinputs_v1 "github.com/mkantzer/k8splayground-cluster-state/schema/dynamicinputs/v1"
	gateway_v1beta1 "sigs.k8s.io/gateway-api/apis/v1beta1"
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
				// only create external route if this network endpoint is not internal only
				if !networkValue.internalOnly {
					let FullName = "\(Name)-\(networkName)-external"
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
								name:        "external-gateway"
								namespace:   "gateways"
								sectionName: "https"
							}]
							hostnames: list.FlattenN(list.Concat([
									[ for sd in X2.apiFirstLevelSubdomainsActual {[
										"\(X2.envSubdomain)\(sd).\(X2.dnsExternalSuffix)",
										if X2.envSubdomain == "" {
										"*.\(sd).\(X2.dnsExternalSuffix)"
									},
								]}],
							]), -1)
							rules: [{
								matches: [{
									path: {
										type:  "PathPrefix"
										value: networkValue.path
									}
								}]
								backendRefs: [{
									name: strings.TrimSuffix(FullName, "-external")
									port: networkValue.servicePort
								}]
							}]
						}
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
