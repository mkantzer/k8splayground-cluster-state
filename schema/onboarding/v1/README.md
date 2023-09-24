# Onboarding v1

## Schema Definition

```cue
package kube

// Map of applications. One app per file.
// Note: ApplicationName == `mesoservice/` subdirectory.
onboarding: [ApplicationName=string]: {
    apiVersion: "v1"
    kind: "Onboarding"
    metadata: {
        labels: {
            // repository that contains your app's source code.
            // Note: do not include `LeagueApps/`.
            repo: string
            // name of team that owns app
            team: string
        }
    }
    spec: {
        // Determines if the application will be deployed to production.
        // Defaults to `false.`
        prod: enabled: bool
    }
}

```

See [interface.cue](interface.cue) for validation rules and defaults.

## Clarifications:

## Changes since Previous Versions
N/A
