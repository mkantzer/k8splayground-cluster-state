# k8splayground-cluster-state

This repo contains a reference design for my opinionated way of managing k8s configuration for an organization's microservices.
The goals of the architecture are:
- Simple user interface.
- Give developers platform-defined best practices and standards for free.
- Improvements as feature releases, not tightly-coupled upgrades.
- Simplified management and development for Platform operators.
- Escapable when needed.

## A note on naming:

The name for "a group of bits that all work together" is hard, and there are a million, already-overloaded terms, such as "Service" or "Application" or "Deployment" or whatever.
We introduce the new term `mesoservice`, vaguely defined as "all the bits needed for some _block_ of an application".
They're usually versioned and deployed together, and their configuration is fundamentally linked. As an example, a single one may contain:
- A long-running container that will serve HTTP Traffic.
- A "job" container that will run a single task and exit (such as database migrations).
- Some networking definitions to route traffic to the HTTP container.
- Some set of "platformy" bits to manage scaling, monitoring, permissions.
- Some set of datastores.

## Usage

### Getting Started as a User

See [Getting Started](./docs/GETTING_STARTED.md)

### Prerequisites

User-facing:
- [cue](https://cuelang.org/docs/install/)
- [helm](https://helm.sh/docs/intro/install/)
- [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/)
- [pre-commit](https://pre-commit.com/#install)

### Install Pre-Commit Hooks

Run the following in the root of the repo:
```bash
pre-commit install
```

### Executing cue commands

All of the following commands should be executed from the deepest directory of an instance (eg `mesoservices/[service_name]`).
Most commands allow you to pass in an argument to determine which `context` to render. 99% of the time, developers will not need to interact with this, and can simply omit the `-t ctx=[value]` (it will default to `prime`).

For additional details on contexts, see [docs/CUE_SCHEMA.md](docs/CUE_SCHEMA.md#Contexts)

#### List Objects

To get a list of what kubernetes objects will be rendered:
```sh
cue -t ctx=prime ls
```

#### Render Cuelang to YAML at STDOUT

To output a YAML document stream of kubernetes manifests (usable without any additional processing):
```sh
cue -t ctx=prime dump
```

### Running tests
execute `./runtests.sh` in the `tests/` directory.

## General Philosophies

### All component integration happens in the templates

I've seen too many organizations build (or use) piles of bespoke code, CI pipelines, and tooling to build things that could be called "Platform Applications".
They're usually characterized by having internals that are system-aware in ways that go beyond the inputs to a specific execution.
Often, doing a major overhaul of how something is handled requires more than input or template changes.

Here, I endeavored to ensure that all integration happens _here, via the versioned templates_.
This way, breaking changes are easily tracked and managed throughout their lifecycle, and be tested via simple procedures.

### Modularity

Be able to fully swap out components by _only_ updating this repo.
For example, we used to use Deployments for running our `deployedServices`, but wanted to swap to `Argo Rollouts` to prepare for canaries.
The entire swap was managed by changing which object we generated in the `mesoservice` schema, without even needing a version change.
Developers need not have noticed.

## Environments and Branching Strategy

## Some Specific, Interesting Choices to Note

### Single, Global config, vs per-env:

See [spicy choice in platform doc](./docs/internal/PLATFORM.md#the-spicy-choice-of-using-a-global-config-vs-per-env).

### Argo Rollouts, instead of Deployments

### Gateway API, instead of Ingress

## Security Note

- `main` is prod.
- even non-main allows arbitrary code execution in lower envs.
- CUE is not an admission controller (though you could probably use it to build one).
- A CI check is not enough, especially if branch protection rules can be overridden. 


## Special Thanks

Special thanks to my employer, [LeagueApps](https://leagueapps.com), for allowing me to upstream my design, so that others can see a non-trivial example of Cuelang-based templating for GitOps.