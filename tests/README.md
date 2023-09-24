# TESTING TENANTS

This directory contains our dedicated testing suite, especially for our schema.
It essentially acts as a final validator / regression tester during CI, checking if various configurations produce the expected YAML.

## Organization
```
tests
├── [test-name]
│   ├── input.cue
│   ├── [context].yml
│   └── [context].yml
└── [test-name]
    ├── input.cue
    ├── [context].yml
    └── [context].yml
```

- `test-name` should be `kebab-case` descriptions of the test, named so that related tests are grouped alphabetically
  - A test to validate a simple use of the `mesoservice` schema's `v1alpha1` version might be called `ms-v1alpha1-basic-app`
  - A test to validate complex networking in the `mesoservice` schema's `v1` version might be called `ms-v1-complex-networking`
- `input.cue` is the entire test-specific cuelang definition. (can be split across files if needed)
- `[context].yml` is the entirety of the expected output of `cue -t ctx=[context] dump`. A given test can have multiple of these.

## Testing

The tests are executed during GitHub Actions, at which point each test, for each provided `[context].yml`, is `cue -t ctx=[context] dump > [context].yml`ed.
The YAML files are then `git-diff`'d, to see if there are any changes from the checked-in (on branch, not `main`) versions.
If so, the test is considered failed.

## Keeping tests up to date

As we iterate on schema, it's highly likely that tests will begin failing: we're changing the output for the given inputs.
In general, this can be handled in one of two ways:

1) Write tests first: write out the full expected YAML, and then iterate on the Schema until it matches desired.
2) Update the schema, and then re-render the various tests. Check each `diff`, and ensure they're as desired. Then commit the changed outputs.

Both are annoying / bad in different ways, but this was the easiest to implement system.

## Managing input tags

To test the injected values defined in `defs_tags.cue`, you **do not** need to mess with the actual execution of the `dump` commands.
The values are still in the primary cue configuration, so you can just set `inputTags: {...}` alongside the rest of the cue in `input.cue`.

## Possible idea for expansion

Right now, we're purely testing `is the rendered text the same?`. This is _easy_, but inflexible and requires constant updates, including to things that aren't actually relevant to a given test.

In the future, I'd like to change this to providing some kind of script, query, or policy, for things like "All of these fields in every deployment must match", "ensure this metadata is set correctly", or other similar checks, that can remain passing if an unrelated change occurs.
