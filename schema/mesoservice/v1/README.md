# Mesoservice v1

User-facing schema to deploy an application with all platform-managed best practices.

## Schema Definition

```cue
package kube

Mesoservice: {
	// Instructs to use _this_ version.
	apiVersion: "v1"
	metadata: {
		// Mesoservice name. Should == directory name.
		name: "schematest"
		labels: {
			// Github Repository that hosts application code.
			repo: "Ealenn/Echo-Server"
			// Name of team that owns the mesoservice.
			team: "Mike"
		}}
	spec: {
		// Map of components that should always be live.
		deployedServices: {
			// Component name. DO NOT re-use your mesoservice name.
			// Instead: use a name descriptive of the role this component plays.
			// Common options are: `app`, `web`, `primary`
			echo: {
				// Minimum number of copies that should be run per environment.
				// Note that this is a base: deployedServices are also autoscaled.
				// Defaults to, and must be >=, 3.
				replicas: 3
				// Artifact repository source for image. Try to use the full URL.
				imageName: "docker.io/ealen/echo-server"
				// ONLY INCLUDE ONE OF imageTag / imageDigest.
				// STRONG preference for imageTag.
				// Docker image tag.
				// "latest" is specifically disallowed. Avoid re-using tags, and 
				// instead keep tags immutable. This is required for k8s to _actually know_
				// when to actually update a running application, and also makes it easier to
				// understand what version is running. In general, I recommend just tagging with the git sha.
				imageTag: "0.8.6"
				// Docker image digest. Note: not the git sha.
				imageDigest: "sha256:ff3b9f1251ce<...>"
				// Map of environment variables to provide to container.
				// Note: values must _always_ be strings.
				envVars: {
					PORT:                "80" // values can be set for all envs at once
					ENABLE__ENVIRONMENT: "false"
					ENABLE__COOKIES: {// values can bet set per-environment.
						default: "true" // sets values for all non-specified environments.
						// Env-type specific customizations. All are optional.
						preview: "false" // overrides value for envs considered "preview".

						// currently available envs are:
						// - `preview`, used for PR or other preview environments.
						// - `prodLike`, the main configuration. This includes the copy of prod in the development cluster, and eventually others. NOT JUST ACTUAL PRODUCTION.
					}
				}
				// for scraping prometheus metrics.
				// Optional. Will not scrape if not defined.
				metrics: {
					path: "/metrics"
					port: 80
				}
				// Used to control pod lifecycle decisions.
				// See the kubernetes documentation for full explanation of values:
				// https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
				probes: {
					startup: {
						initialDelaySeconds: 5
						timeoutSeconds:      3
						httpGet: {
							path: "/probe/startup"
							port: 8080
						}
					}
					// same structure as `startup:`
					readiness: {...}
					liveness: {...}
				}
				// Map of defininitions for how requests to the component should be managed.
				networking: {
					// Endpoint name. DO NOT re-use your mesoservice name, nor your deployedService name.
					// Instead: use a name descriptive of the role this component plays.
					// Common options are: `http`, `api`, `primary`, `websocket`
					primary: {
						// Path-prefix that service is exposed at. Optional.
						// If unset, application cannot be reached outside of cluster.
						// MUST start with a `/`, must NEVER end with `/`.
						// Note: _no_ rewriting occurs. Containers sees path as-is.
						path: "/path/to/my/v1/app"
						// Port that the container is listening on. (Default: 80)
						containerPort: 8080
						// Port (on Service, not LoadBalancer) that clients should address. (Default: 80)
						servicePort: 80
						// When set to false (default) this route will be attached to both external
						// and internal gateways. When set to true, this route will attach only to internal.
						internalOnly: false
					}
					// same structure as `primary`
					secondary: {...}
				}
			}
			// A second always-live component.
			"other-echo": {
				replicas:  3
				imageName: "ealen/echo-server"
				imageTag:  "0.5.1"
				... // truncated for brevity
			}
		}
	}
}
```

See [interface.cue](interface.cue) for validation rules and defaults.

## Provided Environment Variables

`mesoservice` automatically provides many environment variables, in addition to those defined by the user.
These should be used for targeting dependencies, as they are likely to change as Platform needs to make adjustments.

Information and formatting can be found in [rollouts.cue](rollouts.cue): search `EasyPlatformEnvVars`.

## Clarifications:

### `deployedServices:`

This object is used for defining components of a mesoservice that are expected to _always_ be scheduled (note: does not indicate priority, only lifecycle). They may never exit under normal operation, or they may exit after finishing some task. In either case, the expectation is that any terminated pod be immediately replaced.
Examples include containers that serve HTTP requests, or containers that continuously monitor something.
They _roughly_ map to a `Deployment` and its associated components, although Platform reserves the right to change implementation details.

They can be contrasted with `job`s (not yet implemented), which run once, exit when finished, and are not restarted unless they fail.

### Networking Health Checks

Our system has multiple sources of health-checks, to ensure a given pod is ready to receive network traffic.
We primarily rely on the values in the `readiness` probe, if available. We _highly_ recommend configuring it.
If it is _not_ configured, we will instead utilize the configuration for each configured `network`, meaning your application will receive health-checks where it expects normal traffic.

We recommend _not_ logging health-check traffic by default: they are very noisy, and the log storage cost can add up quickly.

## Changes since Previous Versions
N/A
