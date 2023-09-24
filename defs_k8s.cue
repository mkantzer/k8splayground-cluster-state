package tenants

import (
	"strings"
)

kubernetes: [Context=string]: [Kind=string]: [Name=string]: {
	apiVersion: string
	kind:       string
	// Ensure kinds are mapped correctly:
	//  - Kind must be lowecase, to prevent bad casing causing a validation escape
	//  - Kind must be equivilent to kind.
	//  - `kind:` is PascalCase, and you can't do `ToPascal`, so we need to validate in a different field.
	_kindCaseCheck: strings.ToLower(kind) & Kind
	metadata: {
		// name requirements: https://kubernetes.io/docs/concepts/overview/working-with-objects/names
		name: Name & =~"^[a-z0-9]([-a-z0-9]*[a-z0-9])?$"
		// ensure legal and required values: must be empty or consist of alphanumeric, '-', '_', or '.'. Must start and end with alphanumeric.
		labels: [string]: =~"^(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])?$"
		labels: name:     Name
	}
}

// Initialize object for scope reasons
k8sObjects: {}

// Render kubernetes per-kind list into flat list,
// maintianing context-based separation.
for contextName, contextValue in kubernetes {
	k8sObjects: "\(contextName)": [
		for kind in contextValue
		for object in kind {object},
	]
}
