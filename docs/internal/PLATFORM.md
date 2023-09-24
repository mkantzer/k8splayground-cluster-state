# Platform-Specific Notes

This doc holds notes that are relevant for the Platform Team, to help keep this system maintained.

## Helpful Links
- [Useful Cue Patterns](https://cuetorials.com/patterns/): we make heavy use of the Function pattern in our schema.
- [Cuelang Slack](https://join.slack.com/t/cuelang/shared_invite/enQtNzQwODc3NzYzNTA0LTAxNWQwZGU2YWFiOWFiOWQ4MjVjNGQ2ZTNlMmIxODc4MDVjMDg5YmIyOTMyMjQ2MTkzMTU5ZjA1OGE0OGE1NmE): they're super helpful with debugging things
- [Cuelang Playground](https://cuelang.org/play/#cue@export@cue): for isolated cue testing.

## General Overview

### Design Philosophy and Intent

The primary intentions of this system are:
- Provide developers a single, simple, global, behavior-driven interface where they can describe their usage of the platform.
  - Generate all objects from this single interface.
- Shift as much "left" as possible: `main` == `production`, and changes are tested during PRs. This includes configuration updates.
- Give Platform freedom to iterate, expand, test, and adjust as needed.
- Be "simple": this system is _not_ a complex application with databases or runtime behavior. It is _only_ a data templating and rendering system.
  - System behavior is often emergent, rather than explicitly orchestrated. ArgoCD is going to apply everything at once.
- Be flexible, future-ready: We can't predict everything, but we have a rough idea of the kinds of things we'll want. Keep them in mind as we make choices, especially at the interfaces.
- Minimize drift, and control it carefully when it's needed.

The basic plan for this is that application teams will each have a single "mesoservice" object, in which they describe what they need: what dockerfile stages to build, how many replicas they want, any environment variables, routes, or datastores they're going to use. They shouldn't need to write all of their YAML: they just tell us what it needs to _do_: we manage actually getting it to do those things.

This is primarily achieved via the `mesoservice` schema: we make heavy use of the [function pattern](https://cuetorials.com/patterns/functions/) to generate a ton of configuration based on the input schema.
The generated config is organized _primarily_ by `context`, which roughly maps to "which things, in which configuration, do I want to output".
For example, the `prime` context will include things like `deployment`s, `services`, `configmaps`, `httproutes`, for running the application in a production-like manner.
The `workflow` context doesn't have any of that: instead, it's got all of the components needed to run the Managed Build Pipeline for a mesoservice.
All of these contexts are generated together, by every execution of a mesoservice.
The context flag on `cue dump` simply sets which slice gets output to STDOUT as YAML. (You can see this yourself: run `cue eval -c` in `tests/ms-v1-networked`).

Orchestrating which `context` gets deployed where is the responsibility of our _weirder_ schema and context: `onboarding`.
It's managed separately, and is responsible for generating all of the `Applications` and `ApplicationSets` required for the system, as a component of the app-of-apps pattern.
Those `Applications` each declare which directory they should `dump` from, which context they should dump, and what cluster they should be applied to.
ApplicationSets define some method of generating many `Applications` based on some dynamic source.

The intention here is that a single mesoservice will have many different `App(Set)s` at once. Some may even re-use contexts. For example:
- `prod1` `application`, deploying `prime` context to `mk5r-prod1`
- `prod2` `application`, deploying `prime` context to `mk5r-prod2`
- `workflow` `application`, deploying `workflow` context to `mk5r-tools`
- `cloudresources` `application`, deploying `cloudresources` context to `mk5r-cloudresource-gen`
- `app-pr` `ApplicationSet`, deploying `prime` and `smoke` contexts to `mk5r-qa1` in a new namespace for each open PR in the app repo.
- `cs-pr` `ApplicationSet`, deploying `prime`, `qa`, `workflow`, `cloudresources` contexts to `mk5r-qa2` in a new namespace for each open PR in `cluster-state` repo with the label `full-test-ms-1` (which is maybe put there by a github action, based on what files have changed? (the PR generator doesn't have a file filter, only a label one))

See the [context section of CUE_SCHEMA](./CUE_SCHEMA.md#contexts) for additional information on the use and contents of each context.
We'll introduce additional contexts as needed: the primary driver of this will be "Gosh, I need this to do something _different_."

## Repo Workflows

These describe the MVP workflows for using this repo.

### Developer-sourced config update
This includes changes to just the image tag, and broader "mesoservice" changes

1. Developer creates feature branch from `main`
2. Developer makes changes to their `mesoservice:` object
3. Developer opens PR to `main`
   1. Github Actions runs CI checks
   2. A new ArgoCD `Application` is generated by an `ApplicationSet`, which applies a `prime dump` (and anything else needed) of the proposed update _somewhere tbd_.
   3. Developer is provided links as needed to inspect, test.
4. Developer tests their changes, iterates as needed.
5. Platform team reviews / approves PR *
6. Developer merges to `main`

\* PR review requirements should _not_ be relied on as a technical security control. EM's have override permissions. We will need to set up sufficient alerting and technical controls managed _outside_ this repo.

### Platform change: underlying infra (`terraform` stuff)

1. Feature branch in modules repo, make changes
2. Point a test macroservice at the prefab feature branch in `floorplan`
3. Apply test macroservice TF
4. (If relevant) Check that `cluster-state` / argocd is deploying (all apps? some subset?) in a prod-like way to test macroservice
   - Avoid tightly-coupling changes if possible: you may need to generate extra, unused resources in `cluster-state` to prepare for changes.
5. Manually verify functionality within test macroservice
6. PR/merge prefab
7. Update/pr/deploy the rest of the macroservices, in a phased way if desired.

### Platform change: schema updates

1. Platformer creates feature branch from `main`
2. Platformer makes changes in `schema`: _usually_ maintaining version number, but might create a new one if needed.
    1. If a new version is created, test applications may need to be included that use it.
3. Platformer updates or creates new `tests/` entries as relevant
4. Platformer opens PR to `main`
   1. Github Actions runs CI checks
   2. New ArgoCD `Application`s are generated by `ApplicationSet`(s), which applies a `prime dump` (or equivalent) of the proposed update _somewhere tbd_. For now, it should apply _all_ applications.
   3. Platformer is provided links as needed to inspect, test.
5. Platformer tests their changes, iterates as needed.
6. Platform team reviews / approves PR
7. Platformer merges to `main`

For particularly risky or worrisome changes, we can create a new minor or test version: `v1testAddingWorkflows`, or `v1minor2alpha1`, for example. That can go the above process, and merging it won't actually update any services. We can then update certain test applications or volunteers one at a time, to validate again, in production, before promoting it to the new `v1` and rolling it out to everyone.

## Various Scattered Ideas

### Reviewing PRs

- Keep an eye out for top-level `kubernetes:` objects, or _anything_ outside of a `mesoservice:` block. That'll be someone doing something _weird_: ask many questions.
- Review the exported dump-diffs. Make sure you know what's going to change, and communicate any that might impact an app team back to the developers.

### Managed Build Pipelines
- Use context `workflow`
- We'll want to be generating _workflow template_ objects, not _workflow_ objects.
- Updating image tags will be tricky: cue doesn't have anything like an in-place `jq`, due to the scattered-across-files nature of the language. We'll likely need to get _tricky_ with it:
  - Idea 1: Require tags be defined in dedicated `[deployedService].cue` files that _only_ contain `package kube` and a single-line, nested-struct object up to the tag
  - Idea 2: Magic comment like `#update=true,deployedService=[deployedService]`
  - Idea 3: Fully rework the tooling to import _YAML_ into the schema, and then use YQ. (not a _huge_ fan of this).

I think Idea 1 is likely the best: ensure that `mesoservices/[name]/app.cue` doesn't define `mesoservice.spec.deployedServices[name].imageTag`, unless `mesoservice.spec.deployedServices[name].updateImage == false (default true)`. Then, in the managed pipeline, for each `deployedService` where `updateImage == true`, generate and commit a `mesoservices/[name]/[deployedService].cue`, with the format:
```cue
package kube

// GENERATED BY ARGO WORKFLOWS. MANUAL CHANGES TO THIS FILE WILL BE OVERWRITTEN ON THE NEXT PRODUCTION DEPLOYMENT.
// TO LOCK A SPECIFIC TAG, SET THE FOLLOWING IN `app.cue`:
// mesoservice: spec: deployedServices: <name>: imageTag: *<value>
// mesoservice: spec: deployedServices: <name>: updateImage == false

mesoservice: spec: deployedServices: <name>: imageTag: *<gitSha>
```

### The spicy choice of using a Global config, vs per-env

We've made an _explicit_ choice here to use a _single_ `mesoservice` object per mesoservice, instead of one per macroservice. Differences between macroservices are instead handled internally, via `context`s.
This represents a departure from the previous system, where changes were manually promoted through each tier, requiring merges and applies at each step.
We made this choice for a number of reasons, and are taking steps to ensure that you can still test changes before they're released.

Reasons:

- Allows us to explicitly control configuration drift:
  - We can enforce keeping it an an absolute minimum
  - We can test any diffs we decide to introduce
- Simplifies comparisons between environments
- Simplifies managing objects like Applications and Workflows
- Reduces developer-facing complexity of configuration
- Reduces complexity of multi-macroservice environments (devs don't care how many production clusters we have, or all of the QA or ephemeral envs)

Safety:
The previous workflow was roughly:
1. Branch, change, PR, only updating `lapps-qa1`
2. Merge PR, apply `lapps-qa1`
3. Manually test `lapps-qa`
4. Iterate until 3 succeeds
5. Branch, change, PR, merge, apply for the rest of the envs, possibly in phases

The [new workflow for schema updates](#platform-change-schema-updates) provides the same validation opportunity, but _pre_ merge: it deploys a prod-like environment that can be used to test the proposed changes, before they're merged and applied to prod. It just collects it all into a simplified workflow.

### Managing Dynamic Values

For an in-depth explanation, see [defs_tags.cue](../defs_tags.cue).

Essentially, we've got a system to inject values at evaluation time, separate from the context system.
This is primarily for use in dynamically created envs, where we need to set specific config values such as labels and hostnames.

These values are provided by the ArgoCD application(set)s, under the env var "DYNAMICTAGS", as a string of CLI arguments.
These are then consumed by the plugins, which maintain the hard-coded context tag, to prevent escaping via this repo.

### Automatically Provided Environment Variables

As we increase the environmental complexity, we need to decrease the need for complex coordination between platform and application teams.
Part of that is managing how apps receive deploy-specific configuration: instead of apps having hard-coded values for ex: database addresses, we want to provide them at runtime based on the needs and architecture of the platform.
This solves for situations like: "I have 3 pr environments live in mk5r-dev1 at once. How do I make sure app1 in pr1 talks to app2 in pr1, and not app2 in pr2?"

The best practice for things like this is laid out in [12factor](https://12factor.net/config): use fully orthogonal `environment variables` as the primary interface. Here, orthogonal means "one behavior <-> one value": eg: do not have a generic `ENV=<dev|pr|prod>` that changes everything at once.
For sensitive values, we may instead opt to mount a file to a known location.

We should establish a standard convention for the names and value-schema of these variables. A possible convention is documented below.

#### Proposal: Env Var Name and Value conventions

This was first discussed [in slack, here](https://leagueapps.slack.com/archives/C03E38VL7FS/p1690225770221349?thread_ts=1690205423.612649&cid=C03E38VL7FS).

The general name format is `[target-type]_[target-identifier]_[var-type]`: for example `PGSQL_USERS_PASS` or  `REDIS_AUTHZ_PORT`.
- `target-type` indicates what kind of thing the var represents (Another mesoservice? A database? MySQL or Postgres? A Secret Manager entry?). It also indicates what `var-types` will be provided (ex: every `PGSQL` may provide a `HOST` and a `USER`).
- `target-identifier` may be subdivided, with the least-specific identifier at the beginning, and becoming more specific as you move along. In general, a given `target-type` will have a consistent subdivision schema.
- `var-type`s indicate the _thing_ contained in the variable (hostname? port number?). They are consistent in format between target-types: a `PGSQL_<x>_PORT` and a `REDIS_<x>_PORT` would both be raw numbers (`8080`, not `"8080"`).

We should document, in the `mesoservice` schema version `README`s:
- what `target-type`s are provided, and under what circumstances
- the `target-identifier` schema for that `target-type`
- the list of `var-type`s provided under that `target-type`
- the format of each `var-type`

We may also have some variables that we _always_ provide, for things like filling out structured logging. Those should be documented as well.

Some possible `target-types`:

##### **MESO**
An HTTP endpoint for an application container. Could be another Deployed Service within the same mesoservice, or a different mesoservice entirely.

- `target-identifier`: `[mesoservice-name]_[deployed-service-name]_[network-name]`
- `var-type`s: `HOSTNAME`, `PORT`

Conditions to provision:
- All `network`s for all `deployedService`s within the same mesoservice are always provided.
- When a (not yet defined) field in the `mesoservice` schema indicates the need to communicate to a different mesoservice. Field would need to include `mesoservice`, `deployedService`, `network` names, and possibly `port`.

##### **PGSQL**

A Postgres database.

- `target-identifer`: `[mesoservice-name]_[database-name]`
- `var-types`s: `HOSTNAME`, `PORT`, `USER`, `PASS`

Conditions to provision:
- A mesoservice indicates it needs a Postgres database. Indication includes a name for the database (in case they need 2 of the same kind)
- May be provided to all pods in the mesoservice, or only a subset.
- Never provided for a different mesoservice.
