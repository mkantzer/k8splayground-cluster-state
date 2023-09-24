package tenants

import (
	application_v1alpha1 "github.com/argoproj/argo-cd/v2/pkg/apis/application/v1alpha1"
)

// Enforce schema requirements for kinds, and ensure `kind:` is properly PascalCased
kubernetes: onboard: {
	application: [string]:    application_v1alpha1.#Application & {kind:    "Application"}
	applicationset: [string]: application_v1alpha1.#ApplicationSet & {kind: "ApplicationSet"}
}
