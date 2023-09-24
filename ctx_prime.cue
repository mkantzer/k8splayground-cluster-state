package kube

import (
	core_v1 "k8s.io/api/core/v1"
	apps_v1 "k8s.io/api/apps/v1"
	// networking_v1 "k8s.io/api/networking/v1"
	autoscaling_v2 "k8s.io/api/autoscaling/v2"
	// batch_v1 "k8s.io/api/batch/v1"
	// policy_v1 "k8s.io/api/policy/v1"
	// meta_v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	// rbac_v1 "k8s.io/api/rbac/v1"
	podmonitors_v1 "github.com/prometheus-operator/prometheus-operator/pkg/apis/monitoring/v1"
	gateway_v1beta1 "sigs.k8s.io/gateway-api/apis/v1beta1"
	rollouts_v1alpha1 "github.com/argoproj/argo-rollouts/pkg/apis/rollouts/v1alpha1"

	raw_k8s "github.com/mkantzer/k8splayground-cluster-state/schema/raw_k8s"
)

// Enforce schema requirements for kinds, and ensure `kind:` is properly PascalCased
kubernetes: prime: {
	namespace: [string]:               core_v1.#Namespace & {kind:                      "Namespace"}
	service: [string]:                 core_v1.#Service & {kind:                        "Service"}
	configmap: [string]:               core_v1.#ConfigMap & {kind:                      "ConfigMap"}
	serviceaccount: [string]:          core_v1.#ServiceAccount & {kind:                 "ServiceAccount"}
	deployment: [string]:              apps_v1.#Deployment & {kind:                     "Deployment"}
	horizontalpodautoscaler: [string]: autoscaling_v2.#HorizontalPodAutoscaler & {kind: "HorizontalPodAutoscaler"}
	httproute: [string]:               gateway_v1beta1.#HTTPRoute & {kind:              "HTTPRoute"}
	rollout: [string]:                 rollouts_v1alpha1.#Rollout & {kind:              "Rollout"}
	podmonitor: [string]:              podmonitors_v1.#PodMonitor & {kind:              "PodMonitor"}
	healthcheckpolicy: [string]:       raw_k8s.#HealthCheckPolicy & {kind:              "HealthCheckPolicy"}
	...
}
