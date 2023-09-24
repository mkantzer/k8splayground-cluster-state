package main

import (
	_ "k8s.io/api/apps/v1"
	_ "k8s.io/api/autoscaling/v2"
	_ "k8s.io/api/batch/v1"
	_ "k8s.io/api/core/v1"
	_ "k8s.io/api/networking/v1"
	_ "k8s.io/api/policy/v1"
	_ "k8s.io/api/rbac/v1"
	_ "k8s.io/apimachinery/pkg/apis/meta/v1"

	_ "sigs.k8s.io/gateway-api/apis/v1beta1"

	_ "github.com/argoproj/argo-cd/v2/pkg/apis/application/v1alpha1"
	_ "github.com/argoproj/argo-rollouts/pkg/apis/rollouts/v1alpha1"

	_ "github.com/prometheus-operator/prometheus-operator/pkg/apis/monitoring/v1"
)

/*
NOTE: this file is not _actively_ used by the configuration.
Rather, it is used by the `cue` tooling to manage the importing and storage of golang packages, from which cue can then generate schema definitions.

Improving package management within cuelang (and possibly how it imports golang) is an active focus of the cue team.
- https://github.com/cue-lang/cue/discussions/2330

Docs:
- https://cuelang.org/docs/integrations/go/#download-cue-definitions-from-go
- https://github.com/cue-lang/cue/blob/f681271a38ec/doc/tutorial/kubernetes/README.md
*/
