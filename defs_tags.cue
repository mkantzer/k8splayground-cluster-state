package kube

import (
	"strings"
	dynamicinputs_v1 "github.com/mkantzer/k8splayground-cluster-state/schema/dynamicinputs/v1"
)

// This schema defines configuration that can be injected at runtime using tags:
// https://cuetorials.com/patterns/inject/

// Tags are provided to various `cue` subcommands using -t name=value notation
// such as `cue eval -t ctx=prime -t dnsPrefix=test1` or `cue -t ctx=prime dump`

// By design, convention, and default, the Cuelang configuration layer is hermetic:
// there should not be any environmental side effects. This is great when you have
// static configurations, but our environments are dynamic, and require configuration
// to be driven by that dynamism. Specifically, I'm refering to per-pr environments,
// generated by ArgoCD ApplicationSets.

// These environments require specific adjustments to configuration values, such as
// kubernetes metadata labels, or HTTPRoute hostname matching. This is a different kind
// of adjustment from the one handled by contexts: contexts change the overall shape
// and content of what we're rendering, while tags are used to change specific values.

// These tags should _only_ be used to change _specific_ values. If you find yourself
// writing complex comprehensions or dynamically setting chunks of configuration (or even
// whole objects), you're likely better off managing that via contexts.

// We also choose to set these _here_, in the main config, instead of at the tooling level,
// for a number of reasons:
// - We _can't_ actually feed `_tool.cue`-scoped values into the primary configuration (I believe).
// - Doing some kind of `yq` or cue-based transforms _n the tool scope makes it hard to debug via
//    `cue eval`.
// - Doing major dynamism in the `_tool.cue` scope can bloat the tool files.
// - Ease of testing: we can just include an `inputTags` block in `input.cue`s.
// - Ease of defining defaults that are shared across multiple tools, should we need them.

// These values should _never_ be set in a `mesoservices/*/*.cue` file, and developers should
// _never_ expect to directly interact with them. They are purely managed by the platform team,
// and are set either directly in a test's `input.cue`, by an ArgoCD application via [INSERT MECHANISM HERE:
// Most likely as either PARAMETERS or ENV vars], or by hand when testing and debugging.

// The defaults here are set to dummy values, to allow for easy testing and iteration:
// - if they were `null`, they'd need to be set for every local render attempt,
// - if they were the prod values, it would make it hard to do a controled change later
//    (under _this_ scheme, we can update them via a new `onboard` schema version, in a phased manner).

// This object is versioned, in case we need to adjust it later.

// DO NOT USE THIS SYSTEM TO INJECT SECRET VALUES
// ArgoCD will display any values provided by this method in plain-text,
// as will the rendered Kubernetes objects.
// Use normal Kubernetes secret-passing systems.

// The actual _schema_ is hosted in a different package, so that we can also import it into the
// various _other_ schema

// Actually provide values into config
inputTags: v1: dynamicinputs_v1.#Tags & {
	// Percent (`%`) seperated list of first-level subdomains for the API.
	// Used to set `THESE` in `<deeper-subdomains>.<THESE>.lapps-env.io`.
	// DO NOT include trailing `.`'s'
	apiFirstLevelSubdomains: string | *"dummyprefix1%dummyprefix2" @tag(apiFirstLevelSubdomains)
	// Transformed for internal consumption. This is the one you should actually use in cue.
	apiFirstLevelSubdomainsActual: strings.Split(apiFirstLevelSubdomains, "%")

	// String used to set the preview-env specific subdomain.
	// Used to set `THIS` in ex: `<THIS>.api.lapps-env.io`
	// Include a trailing "." when not an empty string.
	envSubdomain: string | *"" @tag(envSubdomain)

	// In production, we want to avoid prefixing the DNS internally:
	// ex: `main-gateway.internal`, intead of `api.main-gateway.internal`.
	// In pr envs though, we make heavy use of them for internal targeting.
	useDnsPrefixesInternally: bool | *true @tag(useDnsPrefixesInternally, type=bool)

	// Target cluster's external gateway DNS. Usually something like `lapps-cicd1.io`.
	dnsExternalSuffix: string | *"mk5r-dummy.io" @tag(dnsExternalSuffix)

	// Determines which type of value we should use for env vars that provide an _#EnvVarValue
	// rather than a single value for all envs.
	envVarGroup: *"prodLike" | "preview" @tag(envVarGroup)

	// Used for setting kubernetes metadata values.
	// Note that label keys (and values?) must be lowercase. This is enforced in `defs_k8s.cue`
	labels: {
		macroservice: string | *"dummymacro"     @tag(macroservice)
		namespace:    string | *"dummynamespace" @tag(ns) @tag(namespace)
	}

	validation: {
		// The #'s are used to prevent unwanted interpolation/escaping. https://cuelang.org/docs/tutorials/tour/types/stringraw/
		// Source: https://stackoverflow.com/questions/106179/regular-expression-to-match-dns-hostname-or-ip-address
		let ValidHostnameRegex = ##"^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$"##
		dnsSuffixPrefix: false && strings.HasPrefix(dnsExternalSuffix, ".")

		apiFirstLevelSubdomains: {
			for val in apiFirstLevelSubdomainsActual {
				mustHaveAtLeast1FirstLevelSubdomain: len(val) > 0 && true
				mustNotHaveTrailingPeriod:           false && strings.HasSuffix(val, ".")
				mustNotHaveLeadingPeriod:            false && strings.HasPrefix(val, ".")
				mustBeValidHostname:                 true && val =~ ValidHostnameRegex
			}
		}

		envSubdomain: {
			let val = inputTags.v1.envSubdomain
			if len(val) > 0 {
				mustHaveTrailingPeriod: true && strings.HasSuffix(val, ".")
			}
			mustNotHaveLeadingPeriod: false && strings.HasPrefix(val, ".")
			mustBeValidHostname:      true && val =~ ValidHostnameRegex
		}
	}
}