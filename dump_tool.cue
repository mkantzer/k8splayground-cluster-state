package kube

import (
	"strings"
	"encoding/yaml"
	"text/tabwriter"
	"tool/cli"
)

// This file defines the primary external interface for this repository:
// a configuration-defined command that renders Kubernetes API YAML that can be directly applied to clusters.
// For additional information on scripting with cue, see:
// - cuetorial's section on scripting: https://cuetorials.com/first-steps/scripting/
// - the official cuelang kubernetes tutorial: https://github.com/cue-lang/cue/blob/f681271a38ec/doc/tutorial/kubernetes/README.md#define-commands
// The commands themselves are configuration-aware, allowing built-in filtering and mutating, just like any other `cue`.
//
// It defines subcommands you can call via `cue cmd <tool name>`. In the case of names that do not overlap built-in commands, you can omit `cmd`.
// In this case, <tool name> is one of either `dump` or `ls`:
// `dump`: outputs the actual YAML as a stream of documents, separated by `---`. It can be piped directly to `kubectl`, or used by an ArgoCD plugin.
// `ls`: outputs a table of resource types and names that will be generated.
// Both commands operate on the `k8sObjects:` top-level object: they don't explicitly read from `mesoservices:` `kubernetes:`, or the like,
//    although those ARE used to _populate_ `k8sObjects`.
//
// All commands should be executed at the deepest level of a given instance, as they should have the full configuration for that instance available.
// Executing them from the root of the repo will either error, or produce empty or misleading results.
//
// The commands take an optional argument (defaulting to `prime` if ommitted), to help define "what" to render.
// It is used as `cue -t ctx=<context> <dump|ls>`. It selects which key within `k8sObjects` to read:
// `k8sObjects` contains a map of context names to lists of kubernetes objects.
//
// The `dump` tool is intended to be a long-term, stable interface for using this repository, even as we change and adapt the internal structure:
// - `cue dump` should always produce a ready-to-apply stream of kubernetes YAML for an instance
// - the `-t ctx=<context>` argument should always be used for filtering that output to relevant objects.
// The purpose is to allow us freedom to iterate soley within this repository: fully reworking the structure should not introduce
// any changes as far as other tooling (such as ArgoCD) is concerned.
//
// ArgoCD plugins should generally avoid us ing `yq` to further adjust the output beyond the dump:
// If additional mustations , additions, or filters are required, those should be built-in at this level, not externally:
// For example, if we wanted to add a specific label to all resources to declare the name of the ArgoCD application that deploys them,
// we would add a new `arg` named `argoApp`, and a transform here that adds it to all objects in k8sObjects.
// We'd also need to ensure it has a sane, workable, obviously-dummy default, to not require CI and local tooling to populate the tag.
// Note: we might instead work to pass it through to the configuration-proper, if it's needed in more complex ways.
//  We should avoid leveraging this in any truly _behavior_ defining ways though: that should be accomplished via a new, dedicated `context`.

// The exception to this rule is for security-related policy enforcement: EM's are empowered to bypass PR approval in this repo,
// so any protections and policies defined _purely_ by the contents of this repo can be trivially bypassed.
// A likely first-order protection would be adjusting the ArgoCD cuelang plugins to execute a _script_, instead of just the dump command:
// That way, you could add things like `yq` calls to ensure we aren't deploying a specific `Kind`, or other methods of checking the dump
// before outputting it. If we do that, we should remember that we should _only_ output the rendered YAML if it passes: ArgoCD expects the full
// stdout to be a YAML stream, so a "validation passed" line would cause an error.
// We _can_ (I think) print debug information on a failure, though.

// Use CLI "args" (kinda) to determine which context to dump
// https://cuetorials.com/patterns/scripts-and-tasks/#scripts-with-args
// usage example: cue -t ctx=local dump
args: {
	ctx: *"prime" |
		"qa" |
		"smoke" |
		"cloudresources" |
		"workflow" |
		"onboard" @tag(ctx) @tag(context) // Unfortunately, we can't put this on a dedicated line
}

command: {
	dump: output: cli.Print & {
		text: yaml.MarshalStream(k8sObjects["\(args.ctx)"])
	}

	ls: output: cli.Print & {
		let Lines = [
			for x in k8sObjects["\(args.ctx)"] {
				"\(x.kind)\t\(x.metadata.name)"
			},
		]
		text: tabwriter.Write(strings.Join(Lines, "\n"))
	}
}
