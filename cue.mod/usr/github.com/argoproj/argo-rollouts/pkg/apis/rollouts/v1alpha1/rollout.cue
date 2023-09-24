package v1alpha1

import (
	core_v1 "k8s.io/api/core/v1"
	meta_v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// Need to manually declare rolloutspec contents, because cue didn't render it correctly.

// Mostly constructed from here:
// https://argo-rollouts.readthedocs.io/en/stable/features/specification/

#RolloutSpec: {
	minReadySeconds:         int | *0
	revisionHistoryLimit:    int | *10
	progressDeadlineSeconds: int | *600
	progressDeadlineAbort:   bool | *false
	replicas?:               int
	selector:                meta_v1.#LabelSelector
	analysis:                #AnalysisRunStrategy
	strategy:                #RolloutStrategy
	template:                core_v1.#PodTemplateSpec
	// Here for reference, but we shouldn't actually use it in manifests.
	// Setting this back to `false` to unpause via tooling is a thing.
	// Maybe via Argo Events, later.
	paused?: bool
}
