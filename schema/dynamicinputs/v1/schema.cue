package v1

#Tags: {
	apiFirstLevelSubdomains: string
	apiFirstLevelSubdomainsActual: [...string]
	envSubdomain: string

	useDnsPrefixesInternally: bool
	dnsExternalSuffix:        string
	envVarGroup:              string
	labels: {
		macroservice: string
		namespace:    string
	}

	// Don't actually care about the shape of this: leave that to defs_tags.
	validation: {...}
}
