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
