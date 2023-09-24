package raw_k8s

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// This schema defines the resource that allows a GCP load balancer to validate a given application
// is healthy and ready to serve traffic.

// Generic API client spec:
//   https://cloud.google.com/compute/docs/reference/rest/v1/healthChecks
// CRD spec:
//   https://github.com/GoogleCloudPlatform/gke-networking-recipes/blob/main/gateway-api/config/servicepolicies/crd/standard/healthcheckpolicy.yaml

#HealthCheckPolicy: {
	apiVersion: "networking.gke.io/v1"
	kind:       "HealthCheckPolicy"
	metadata:   metav1.#ObjectMeta
	spec: {
		default: {
			checkIntervalSec?:   int & >=1 & <=300
			healthyThreshold?:   int & >=1 & <=10
			timeoutSec?:         int & >=1 & <=300
			unhealthyThreshold?: int & >=1 & <=10
			logConfig?: enabled: bool
			config: {
				type: "TCP" | "HTTP" | "HTTP2" | "HTTPS" | "GRPC"
				grpcHealthCheck?: {
					grpcServiceName?:   =~#"[\x00-\xFF]+"#
					port?:              int & >=1 & <=65535
					portName?:          =~"[a-z]([-a-z0-9]*[a-z0-9])?"
					portSpecification?: "USE_FIXED_PORT" | "USE_NAMED_PORT" | "USE_SERVING_PORT"
				}
				httpHealthCheck?: {
					host?:              =~#"^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$"#
					port?:              int & >=1 & <=65535
					portName?:          =~"[a-z]([-a-z0-9]*[a-z0-9])?"
					portSpecification?: "USE_FIXED_PORT" | "USE_NAMED_PORT" | "USE_SERVING_PORT"
					proxyHeader?:       "NONE" | "PROXY_V1"
					requestPath?:       =~#"\/[A-Za-z0-9\/\-._~%!$&'()*+,;=:]*$"#
					response?:          =~#"[\x00-\xFF]+"#
				}
				http2HealthCheck?: {
					host?:              =~#"^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$"#
					port?:              int & >=1 & <=65535
					portName?:          =~"[a-z]([-a-z0-9]*[a-z0-9])?"
					portSpecification?: "USE_FIXED_PORT" | "USE_NAMED_PORT" | "USE_SERVING_PORT"
					proxyHeader?:       "NONE" | "PROXY_V1"
					requestPath?:       =~#"\/[A-Za-z0-9\/\-._~%!$&'()*+,;=:]*$"#
					response?:          =~#"[\x00-\xFF]+"#
				}
				httpsHealthCheck?: {
					host?:              =~#"^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$"#
					port?:              int & >=1 & <=65535
					portName?:          =~"[a-z]([-a-z0-9]*[a-z0-9])?"
					portSpecification?: "USE_FIXED_PORT" | "USE_NAMED_PORT" | "USE_SERVING_PORT"
					proxyHeader?:       "NONE" | "PROXY_V1"
					requestPath?:       =~#"\/[A-Za-z0-9\/\-._~%!$&'()*+,;=:]*$"#
					response?:          =~#"[\x00-\xFF]+"#
				}
				tcpHealthCheck?: {
					port?:              int & >=1 & <=65535
					portName?:          =~"[a-z]([-a-z0-9]*[a-z0-9])?"
					portSpecification?: "USE_FIXED_PORT" | "USE_NAMED_PORT" | "USE_SERVING_PORT"
					proxyHeader?:       "NONE" | "PROXY_V1"
					request?:           =~#"[\x00-\xFF]+"#
					response?:          =~#"[\x00-\xFF]+"#
				}
			}
		}
		targetRef: {
			group:      ""
			kind:       "Service"
			name:       string
			namespace?: =~#"^[a-z0-9]([-a-z0-9]*[a-z0-9])?$"#
		}
	}
}
