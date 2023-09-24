package tenants

import (
	mesoservice_v1 "github.com/LeagueApps/tenants/schema/mesoservice/v1"
)

// This file is used for defining and transforming the `mesoservice:` object into
// the appropriate `kubernetes:` resources, utilizing the function-like schema
// defined by `schema/mesoservice/`

// Note that the `mesoservice:` object is only intended to be utilized by instances
// within the `mesoservices/` directory.

// Format validation
mesoservice: mesoservice_v1.#Mesoservice // | leagueApp_v1alpha2.#Mesoservice

// Initialize field, so it can be referenced outside the `if` scopes
appGenerator: {}

// Call functions based on versions
if mesoservice.apiVersion == "v1" {
	appGenerator: mesoservice_v1.#Generator & {
		in: {
			metadata: mesoservice.metadata
			spec:     mesoservice.spec
		}
		tags: inputTags.v1
	}
}

// Handle output
kubernetes: {
	appGenerator.out.kubernetes
	...
}
