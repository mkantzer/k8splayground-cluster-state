# Manual Changes to imported packages

Sometimes, an imported/generated schema (usually from golang) does not end up accurately reflecting an API.

Most commonly, this impacts field optionality. `Cue` is evaluated as flat and additive, so we cannot change a field declared as required in `gen/` to optional in `usr/`.

This file tracks manual edits to files in `cue.mod/gen/`.

### Change List

<!--
Ensure all entries are formatted as:
`<full path to file from root>`:
- [`<complete schema to changed field>` - <change made>](link to change in github: commit, possibly including file/line ref)
  - explanation for change
 -->

`cue.mod/gen/github.com/GoogleCloudPlatform/prometheus-engine/pkg/operator/apis/monitoring/v1/types_go_gen.cue`:
- [`#PodMonitoringStatus: observedGeneration:` - made optional](https://github.com/LeagueApps/tenants/pull/4/commits/47930ac3980288f177a3d5ca86575ef2e5fec90a)
  - Field managed by controller. Asserting via argocd would cause thrashing.
- [`#PodMonitoring: status:` - made optional](https://github.com/LeagueApps/tenants/pull/4/commits/a37ee508805708571d999454b630a3c519f348b5#diff-d0cad7dd256629ac9da60ea1ddd7ff71e75959cd74efcd299b70cb293be842d6L216)
  - Field managed by controller. Asserting via argocd would cause thrashing.
