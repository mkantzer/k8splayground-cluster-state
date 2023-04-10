package main

import (
	_ "k8s.io/api/apps/v1"
	_ "k8s.io/api/core/v1"
	_ "k8s.io/api/networking/v1"
	_ "k8s.io/api/autoscaling/v2"
	_ "k8s.io/api/batch/v1"
	_ "k8s.io/api/policy/v1"
	_ "k8s.io/apimachinery/pkg/apis/meta/v1"
	_ "k8s.io/api/rbac/v1"


	_ "github.com/argoproj/argo-cd/v2/pkg/apis/application/v1alpha1"
)
