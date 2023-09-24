# Repo Layout

This structure of this repo is primarily dictated by how `cuelang` prefers modules to be organized. For additional background, see [the cue docs](https://cuelang.org/docs/concepts/packages/)

## Helpful cue terms and context

- `module`: an entire configuration hierarchy. Basically, "this repo".
- `package`: a group of files that go together.
  - All top-level and instanced files should be in `tenants`.
  - No developer should expect to ever write a file in a package other than `tenants`
  - Our schema'd packages should be in a package with a same name as their `apiVersion`, which is also the name of the subdirectory that contains that version.
- `instance`: the directory context in which a package is evaluated: Only files belonging to that package in that directory and its ancestor directories within the module are combined.

The cue docs explain:
> Using this approach, the different kind of directories within a module can be ascribed the following roles:
>
> - module root: schema
> - medial directories: policy
> - leaf directories: data
>
> The top of the hierarchy (the module root) defines constraints that apply across the organization. Leaf directories typically define concrete instances, inheriting all the constraints of ancestor directories. Directories between the leaf and top directory define constraints, like policies, that only apply to its subdirectories.

## Our Layout

### `cue.mod/`

Contains our module declaration, as well as a copy of all imported packages. Cue evaluations are `hermetic`, and expect all config to already be present: no runtime fetching. These _are_ checked in to source control (unlike ex: node_modules).
- `cue.mod/gen/`: files generated from external sources (such as golang struct renders from the k8s api)
- `cue.mod/pkg/`: copies of external cue packages
- `cue.mod/usr/`: user-defined constraints on external definitions

### `docs/`

As you probably guessed, this folder contains documentation.
- `docs/`: common, user-facing stuff
- `docs/internal`: stuff that generally only the platform team has to worry about
- `docs/external`: user-facing stuff that is less commonly needed

### `onboarding/`

Contains configuration used to onboard applications to the system. Defines meta-configuration, such as what directory the true configuration lives in, and what environments to deploy to. Primarily used to generate ArgoCD `Application`s and `ApplicationSets`.

For specific usage, see [here](onboarding/README.md)

```
onboarding
├── [service-name].cue
└── [another-service-name].cue
```

### `mesoservices/`

Contains our `instance`s. All application-specific configuration lives within this directory. Mesoservices are expected to be organized as follows:

```
mesoservices
└── [service-name]
    ├── [filename: default to `app`].cue
    └── [another filename, if needed].cue
```

- `[project-name]/*.cue`: contains configuration values that are shared between all environments.
  - **THIS IS WHERE ALL INSTANCES ARE ROOTED, AND WERE ALL CUE EVALUATIONS ARE RUN FROM**.

You can also include non-`.cue` files (such as READMEs), but they will not be included in any cuelang evaluations.

<!-- > Note: if you are deploying an application using helm or kustomize, a similar structure is expected, and evaluations will still be run from `[project-name]/[environment-name]/`. -->

### Schema

Contains our internal schema definitions and abstractions. Schema are organized as follows:

```
schema
└── [schema-name]
    ├── README.md
    ├── [version]
    │   ├── README.md
    │   ├── interface.cue
    │   ├── [transform-name].cue
    │   └── [transform-name].cue
    └── [version]
        ├── README.md
        ├── interface.cue
        ├── [transform-name].cue
        └── [transform-name].cue
```

- `[schema-name]/README.md` should define the purpose of the schema, the list of currently-supported versions, and any version deprecation notices.
- `[schema-name]/[version]` should generally follow the Kubernetes api versioning model: `v1alpha1` -> `...` -> `v1` -> `...`
  - A new version should only be created upon _breaking changes_, or _stable releases_.
    - Version bumps are not required for all new features, or even most. They _may_ require intentional activation in config, if sufficiently 🌶️.
  - All currently-supported versions should remain present in `main`.
    - Fully deprecated versions _may_ be removed, or otherwise disabled.
- `[schema-name]/[version]/README.md` should include a fully-utilized, well-commented example of how to use the schema. It should also include any required definitions or explanations, and a list of breaking changes from the previous version(s).
- `[schema-name]/[version]/interface.cue` should contain the primary input/output schema definitions and transforms. It is "user-facing".
- `[schema-name]/[version]/[transform-name].cue` should contain the various transforming "functions" called by `interface.cue`.

Our primary schema is `mesoservice`, which is an application-owner facing simplified abstraction layer around our defaults for running an application in Kubernetes.

### `tests/[test_name]/`

Contains various test instances, for validating schema and checking for regressions.
See [the test documenation](../tests/README.md) for more information.

### `[command]_tool.cue`

Configuration files for cue scripts. There are some examples in [the kubernetes tutorial](https://github.com/cue-lang/cue/blob/f681271a38ec/doc/tutorial/kubernetes/README.md#define-commands). These are all executed as `cue [command] [args]`, and should be executed from `instance` roots.

Our current commands are:
- `cue dump`: outputs the rendered kubernetes YAML for an instance
- `cue ls`: outputs a tab-separated table of `[kind] [name]`s that the instance will generate.

### Other files

- `defs_k8s.cue`: fundamental definitions of our kubernetes schema
- `defs_tags.cue`: manages CLI inputs for dynamic values.
- `mesoservice.cue`: manages transform of `leagueApp` versions to our `kubernetes:` object
- `imports.go`, `go.mod`, `go.sum`, `go-import.sh`: used for importing golang structs to cuelang schema.
