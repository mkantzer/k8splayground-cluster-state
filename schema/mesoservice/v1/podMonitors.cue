package v1

import (
	podmonitors_v1 "github.com/prometheus-operator/prometheus-operator/pkg/apis/monitoring/v1"
	dynamicinputs_v1 "github.com/mkantzer/k8s-playground-cluster-state/schema/dynamicinputs/v1"
	"list"
)

_#PodMonitorsOutput: [Context=string]: podmonitor: [string]: podmonitors_v1.#PodMonitor

_#PodMonitorsGenerator: {
	// Input for the caller
	X1=in:   #Input
	X2=tags: dynamicinputs_v1.#Tags
	// Output for the caller
	out: _#PodMonitorsOutput

	// Intermediate fields
	// Base podmonitors generation, without context-specific mutations
	_podmonitorsBase: {
		for dsName, dsValue in X1.spec.deployedServices if dsValue.metrics != _|_ {
			let Name = "\(X1.metadata.name)-\(dsName)"
			let NonNameLabels = {
				for labelKey, labelValue in X1.metadata.labels if labelKey != "name" {
					"\(labelKey)": labelValue
				}
				X2.labels
			}

			"\(Name)": {
				apiVersion: "monitoring.coreos.com/v1"
				kind:       "PodMonitor"
				metadata: {
					name: Name
					labels: {
						name: Name
						NonNameLabels
					}
				}
				spec: {
					selector: matchLabels: {
						name: Name
						NonNameLabels
					}
					podMetricsEndpoints: [{
						interval: "5s"
						path:     dsValue.metrics.path
						port:     dsValue.metrics.port
					}]
					//https://cloud.google.com/stackdriver/docs/managed-prometheus/setup-managed#reserved-labels
					let ReservedLabels = [
						"cluster",
						"instance",
						"job",
						"location",
						"namespace",
						"project_id",
					]
					podTargetLabels: fromPod: [
						for labelKey, labelValue in NonNameLabels if !list.Contains(ReservedLabels, labelKey) {
							from: labelKey
						},
					]
				}}
		}
	}

	// Set Outputs
	out: {
		prime: podmonitors: _podmonitorsBase
	}
}
