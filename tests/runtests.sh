#!/bin/bash

# Simple script for rendering every test.
# NOT for use in github action, where we want each test split into a matrix for
# parallelization and management.

list=$(find . -mindepth 1 -maxdepth 1 -type d )

for i in $list; do
  echo $i
  pushd $i > /dev/null
  for ctx in *.yml; do
    # Strip file extension to get dump context
    truectx=${ctx%.*}
    echo "Dumping context: ${truectx}"
    # Do the dump, branch on success/fail
    cue -t ctx=${truectx} dump > ${truectx}.yml
  done
  popd > /dev/null
  echo "---"
done
