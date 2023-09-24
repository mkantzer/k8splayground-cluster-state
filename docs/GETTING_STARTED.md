# Onboarding to Tenants

This document details the process for onboarding a new component onto the kubernetes platform

## Definitions

Naming is hard, especially in this space; lots of terms are overloaded with multiple technical meanings.
We have defined some specific terms for Platform use, to avoid further reuse and (hopefully) provide some clarity. 
We also provide some definitions for platform resources that may be helpful to a Prod-Eng user who is not familiar with the landscape.

-   `Mesoservice`: Our term for "All your stuff" / "Your whole application" / "The collection of stuff required to run a specific domain of the LeagueApps Product". (You may also think "microservice" or "service" or "application" or similar, but those terms are already in use)
-   `Deployed Service`: A component of a `mesoservice` that describes a workload that is expected to _always_ be scheduled. The typical example is `a container that runs a webservice and receives HTTP requests`.
-   `Network`: A component of a `deployed service` that describes a networking endpoint where other components can expect to reach it.
-   `Environment`: A specific instantiation of a `mesoservice`. Typical examples may include: `prod` (production), qa (dedicated Quality Assurance production replica), [number]-cs-pr (An ephemeral test environment stood up for validating a specific pull request to the `k8splayground-cluster-state` repo.)

External Definitions:

-   `ArgoCD`: a continuous-delivery tool: it watches git repositories and automatically updates Kubernetes based on their contents. This is different from an event-based deployment pipeline, as it will automatically adjust in-cluster resources if they are modified or deleted out-of-band.
-   `Application`: An `ArgoCD` resource that instructs it to deploy the configuration stored in a specific place to a specific environment.
-   `ApplicationSet`: An `ArgoCD` resource that dynamically generates `applications` based on various rules.

## System Overview

The primary purpose of this repo — and the `Platform` team in general — is to empower Product Engineering teams to own their own operations, without requiring them to become experts in infrastructure.
We do this via an abstraction and templating layer: Prod-Eng teams provide simple, behavior-driven inputs which the Platform team inflates into all resources needed to achieve that behavior.
This lets us keep things standardized an best-practiced, while giving teams flexibility and the ability to self-service.

### Separation of Ownership

A part of this model is a clear delineation of responsibility, with a general guiding principal of giving ownership for each piece to the team with the most knowledge, visibility, and means to fix it.

The Platform team owns:

-   overall maintenance of shared platform components (k8s clusters, argocd, etc).
-   defining and implementing platform behavior
-   maintenance of the `cluster-state` repo, including global schema definitions.
-   defining and implementing the interfaces with Prod-Eng teams (with their input)
-   maintenance and development of the templating system and the things it will generate.

The Prod-Eng teams own:

-   their mesoservice's source code.
-   their mesoservice's lifecycle events.
-   their mesoservice's Dockerfiles (and for now, build pipelines)
-   onboarding their mesoservice to the platform, and defining and updating their configuration.
-   testing, validation, and overall functionality of their mesoservice, in both pre-prod and prod.
-   making feature and enhancement requests to the Platform team when they realize they have an uncovered requirement.

### General Overview

-   The `cluster-state` repo holds declarative config.
-   Each mesoservice has a single config, rather than one per environment.
-   Configuration is written in [`cuelang`](https://cuelang.org). Prod-Eng teams are not expected to have a deep understanding of the language.
-   Prod-Eng teams own the configuration for their mesoservice
-   Platform owns the transformation of simplified config to full kubernetes resource specs
-   ArgoCD watches the `tenants` repo, and deploys generated resources to various kubernetes clusters clusters based on predefined rules.
-   This repo uses a simplified trunk-based branching strategy, and all operations are based on repo state:
    -   The only long-lived branch is `main`.
    -   There are _no_ release branches, nor tags.
    -   `main`branch is "production": **every** commit to `main` is an instruction to **immediately** update production.
    -   `main` is protected, and updates require a PR and approval by Platform.
        -   Platform approval is purely for checking the configuration for syntax and security.
        -   Platform _is not_ responsible for test or validation of functionality.
    -   Clicking "merge" (and therefor triggering a production deployment) is the responsibly of the Prod-Eng team
    -   pre-production environments for testing updates are generated dynamically by ArgoCD
        -   each PR in `tenants` triggers the creation of a dedicated Prod-like stack of all applications onboarded to the system.
        -   Each environment has a dedicated, predictable subdomain
        -   pre-prod environments share persistent datastores (per mesoservice)
        -   pre-prod environments are destroyed upon merge

## Prerequisites

-   A mesoservice that's ready to start being deployed to real infrastructure.
-   Any (non-dns-or-load-balancer) Cloud resources (such as IAM or datastores) have been created in `<external terraform repo>`.
    -   They will need to be deployed to all cloud accounts. (Eventually we'll pull that into here)
-   The [cuelang cli](https://cuelang.org/docs/install/) installed.

## Onboarding Procedure

Onboarding happens in 2 stages, via 2 PR's: the first instructs ArgoCD to begin including the `mesoservice` in PR environments, while the second defines the actual mesoservice configuration (and instructs ArgoCD to deploy it to production once merged).

Initial Bootstrapping:

1. Create a new branch from `main`
2. Create a new `.cue` file in `onboarding/`, with the same name as your mesoservice.
3. Ensure file starts with `package tenants`
4. Define your configuration within `onboarding: <YOUR APP'S NAME>:`.
    - See [`onboarding` schema docs](../schema/onboarding/README.md) for field reference.
    - **DO NOT** enable production deployments (i.e. do not set `prod: enabled: true`)
5. Open PR to `main`, and ensure the `Platform` team is added as reviewers.
    - After receiving approval, the service-owning team is responsible for merging.

Initial Mesoservice Configuration:

1. Create a new branch from `main` in `tenants`.
2. Create a new subdirectory under `mesoservices/`, with the same name as your mesoservice.
3. Create `.cue` files containing all configuration.
    - 99% of the time, you will only need a single file.
    - Begin all files with `package tenants`.
    - 99% of the time, you will want to use the `mesoservice:` top-level object. See [schema documentation](schema/mesoservice/README.md).
4. Open a **Draft** PR to `main`.
5. Validate and test in the provided test environment.
6. Enable production deployments in `onboarding/`.
7. When ready to promote to production:
    - add and fill out the below template in the `description`.
    - convert PR from draft to `Ready for Review`.
    - tag `Platform` for review.
8. After receiving approval, the service-owning team is responsible for merging.

### Checklist / Template for Onboarding PR Description

```markdown
-   [ ] Team acknowledges separation of responsibility and ownership of their configuration and lifecycle.
-   [ ] Team acknowledges understanding that **ALL merges to `main` are IMMEDIATELY** deployed to production.
-   [ ] Team acknowledges understanding that reverting a change is managed via git by opening a revert PR.
-   [ ] Team has joined the [#team-platform](https://dead-link) channel in Slack, where they will receive updates and deprecation notices.
-   [ ] Team agrees to respect published deprecation timelines and update in a timely fashion.
```

## "Day 2" Operations

### Updating a mesoservice

This generally follows the same pattern from `Initial Mesoservice Configuration` in [Onboarding Procedure](#onboarding-procedure):
Initial Mesoservice Configuration:

1. Create a new branch from `main` in `tenants`.
2. Update `mesoservice/<name>/*.cue` files as needed.
3. Open a **Draft** PR to `main`.
4. Validate and test in the provided test environment.
5. When ready to promote to production:
    - convert PR from draft to `Ready for Review`.
    - tag `Platform` for review.
6. After receiving approval, the service-owning team is responsible for merging.

### Monitoring generated resources

In addition to our normal monitoring tools, you can see the status of the deployed resources by going to ArgoCD.
You can filter by label on the left-hand-side: most useful will likely be `mesoservice=<name>` and `type=[prod | cs-pr]`.

### Reverting a bad release

If you need to undo a release for any reason:

1. Navigate to the PR that introduced the problem.
2. Scroll down to the "merged commit <hash> into `main`" event, and click `Revert`.
3. Fill out PR details, ensure `Platform` is added as a reviewer, and click `Create`.
4. Notify Platform at #team-platform that you need approval for a prod revert ASAP.
    - In an emergency, or after-hours, an EM can bypass the approval block. In the event that this is used:
        - **DO NOT** bypass the CI checks: if they fail, the merged code won't render.
        - **DO NOT** merge through anything other than a revert, or updates to existing `mesoservice:` blocks. NO hard-coded `kubernetes:` objects may be created in this way.
        - **Immediately** post details to slack, including who merged and why.

### System updates and feature releases

This system is under constant development as the Platform team works to deliver more features and capabilities, primarily through updates to the `schema/*/*`'s, either adding to an existing schema version, or creating a new version.

Updates to existing schema are backwards-compatible, and Platform will endeavor to ensure that existing functionality does not break.
Purely-additive updates may not require any action by Prod-Eng teams, and will be automatically enabled with sane defaults.
Others may be disabled by default, and will require Prod-Eng teams to add additional configuration to enable.

Updates that introduce breaking changes, either in the schema definition or system behavior, will always be new versions.
Upgrade guides will be published by the Platform team.
Prod-Eng teams will be able to update at their convenience, but must do so before their current version is deprecated.

All announcements related to this system will be in the `<CHANNEL NAME>` channel in slack. These include:

-   feature releases, enhancements, or updates for existing schema versions.
-   new schema versions, and what needs to be done to update to them.
-   deprecation notices and timelines for old schema versions.

### Requesting enhancements and new features

The Platform team has a number of features they are already targeting to add to this system, based on current application requirements, and our own design goals. 
We will also be in constant communication with teams to try to discover upcoming needs and current pain-points, to help us design, prioritize, and implement updates.

However, we cannot know everything that every Prod-Eng team is working on or designing for.
We ask that teams be proactive about informing us of upcoming requirements, and their timelines, as soon as they are discovered. This way, we can have them ready by the time you need to use them.
