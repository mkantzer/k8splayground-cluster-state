package kube

import (
	onboarding_v1 "github.com/mkantzer/k8splayground-cluster-state/schema/onboarding/v1"
)

// This file is used for defining and transforming the `onboarding:` object into
// the appropriate `kubernetes:` resources, utilizing the function-like schema
// defined by `schema/onboarding/`.

// Note that the `onboarding:` object is only intended to be utilized by instances
// within the `onboarding/` directory.

// Format validation
onboarding: [Name=string]: onboarding_v1.#Onboarding & {
	metadata: name: Name
}

// Initialize field, so it can be referenced outside the `if` scopes
onboardGenerator: [string]: {}

// Call functions based on versions
for msName, msValue in onboarding {
	if msValue.apiVersion == "v1" {
		onboardGenerator: "\(msName)": onboarding_v1.#Generator & {in: {
			metadata: msValue.metadata
			spec:     msValue.spec
		}}}
}

// Handle output
kubernetes: onboard: {
	for _, value in onboardGenerator {
		value.out.kubernetes
	}
	...
}
