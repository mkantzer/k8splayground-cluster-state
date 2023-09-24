# PR Review Guidance

This document outlines things to look for while reviewing a Pull Request.

## General Guidance

### Naming

#### Mesoservice Config Names
- Mesoservices should NOT include `service` in their name. (ex: `cart`, not `cart-service`)
- Try to avoid re-using the same name across multiple  nested depths of config. At each depth, the name should be descriptive of what _that specific_ instance of a resource is for.
  - EX: (fake) Mesoservice `orders` might have a deployedService `web` that operates as the primary web-server. It in turn has networks `api` and `webhook`, for the different internal endpoints it serves. It may also have a deployedService `worker` with no networks, as it just reads tasks off of a pub/sub.

#### Platform-Generated Names
- Generated k8s objects should be named so that they go from least-specific to most-specific. For example:
  - `Service`s are named `[mesoservice]-[deployedService]-[network]`
  - `HTTPRoute`s are named `[mesoservice]-[deployedService]-[network]-<internal|external>`
- Do Not include namespaces in the object name.

## Specific PR Types

### Onboarding
- Should only include changes to a specific, single `onboarding/[name].cue` file.
- Ensure that the file only includes a single object: `onboarding: [name]:`.
- Ensure naming does not include `service`.
- If initial onboard, ensure that:
  - The PR template was included, and all boxes are checked.
  - Prod is disabled.
- Check the generated PR comment, expanding the changes, to make sure that it's only adding or modifying components for that mesoservice.

### Mesoservice Config PRs

- Wait to approve until explicitly asked: approvals are revoked at each new commit.
- Should only include changes to files in a single `mesoservices/[name]/`.
- In general, there should only be a single file, named `app.cue`
- There may also be a `README.md`, though it is not required.
- There should _not_ be anything outside of a single, top-level `mesoservice` object.
  - `kubernetes:` or `k8sObjects` objects should only be used in cases where all other options aren't viable.
  - PRs adding or updating non-`mesoservice` objects require additional, careful review.
- Names should conform to the [naming rules](#mesoservice-config-names).
- Inspect the generated PR comment:
  - Ensure the only changes are to the mesoservice for the PR.
  - Ensure the rendered correctly correspond to the changes in the PR.

### Schema Changes (Cuelang, not database)

- Review for breaking changes. If changes are breaking, we likely need a new version.
  - Primary indicator: changes to the input schema that are not backwards-compatible, such as new required fields or format changes.
  - Additional indicator: new behaviors that will cause previously-functional apps to break.
- Review the generated PR comment:
  - Review changes to rendered outputs, making sure they're changing as expected.
- Review changes to `tests/`:
  - Ensure that updates to the schema are reflected in either updates to existing tests, or wholly new tests.
  - Ensure that the test output reflects desired outcomes.
- If changes are not breaking, but are sufficiently concerning, a test-version is used before updating the prime.
  - ex: modifying existing behavior, or introducing a diff between dev/prod.
  - Test versions might be named `v1-adding-monitoring`, for example.
  - Use of test versions are allowed in `main` for:
    - Specific, dedicated test mesoservices, owned by Platform
    - ProdEng Mesoservices that have volunteered for a specific test. Ex: they want to test a proposed feature.
- Ensure changes have been tested in the PR env, and that things are still working.
  - The author of the PR is responsible for actually _validating_ functionality.
  - The reviewer of the PR is responsible for ensuring the author has validated, and for proposing additional checks.
