# Cuelang Analysis

## Schema Tests
{{- if not .test.errored}}
> tests rendering:   ✅
{{- else}}
> tests rendering:   ❌

<details><summary>Show Errored</summary><blockquote>
{{- range $instance, $contexts := .test.errored }}
<details><summary>{{ $instance }}</summary><blockquote>
{{- range $contexts }}
* <code>{{ . }}</code>
{{- end}}
</blockquote></details>
{{- end}}
</blockquote></details>
{{- end}}

{{- if not .test.changed }}
> tests passing:     ✅
{{- else}}
> tests passing:     ❌

**Unexpected diffs:**
{{- range $instance, $contexts := .test.changed}}
<details><summary><code>{{ $instance }}</code></summary><blockquote>
{{- range $key, $diff := $contexts }}
<details><summary><code>{{ $key }}</code></summary><blockquote>

```diff
{{ $diff }}
```
</blockquote></details>
{{- end}}
</blockquote></details>
{{- end}}
{{- end}}

## Mesoservice Changes
{{- if not .meso.errored}}
> mesoservices rendering: ✅
{{- else}}
> mesoservices rendering: ❌

<details><summary>Show Errored</summary><blockquote>
{{- range $instance, $contexts := .meso.errored }}
<details><summary>{{ $instance }}</summary><blockquote>
{{- range $contexts }}
* <code>{{ . }}</code>
{{- end}}
</blockquote></details>
{{- end}}
</blockquote></details>
{{- end}}

{{- if not .meso.changed }}

**NO CHANGES**
{{- else}}

**Instance Changes**
{{- range $instance, $contexts := .meso.changed}}
<details><summary><code>{{ $instance }}</code></summary><blockquote>
{{- range $key, $diff := $contexts }}
<details><summary><code>{{ $key }}</code></summary><blockquote>

```diff
{{ $diff }}
```
</blockquote></details>
{{- end}}
</blockquote></details>
{{- end}}
{{- end}}

# Test Environment Information

**external hostname:** `{{ .meta.prnumber }}-k8scspr.dev-api.kantzer.io`
**internal hostname:** `{{ .meta.prnumber }}-k8scspr.main-gateway.internal`
The above values do not reflect any custom subdomains, nor deployments to alternate environments.
If you are making use of either feature, please make sure you adjust your calls as needed.

Please note: it may take a moment for the DNS to become resolvable.

**PUT USEFUL TEMPLATE-ABLE LINKS HERE**
