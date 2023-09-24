# Onboarding configuration

This directory contains configuration for onboarding applications to the platform.

## Schema Structure

See [`onboarding` schema docs](../schema/onboarding/README.md)

## Onboarding a new application

1. Create a new branch from `main`
2. Create a new `.cue` file in this directory, named the same as your mesoservice
3. Ensure file starts with `package kube`
4. Define your configuration within `onboarding: <YOUR APP'S NAME>:`.
   - See [`onboarding` schema docs](../schema/onboarding/README.md) for field reference.
5. Open PR to `main`, and ensure the `Platform` team is added as reviewers.
   - After receiving approval, the service-owning team is responsible for merging.

For a more in-depth guide, refer to the [getting started documentation](./../docs/GETTING_STARTED.md).
