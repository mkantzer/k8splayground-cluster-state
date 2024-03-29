// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/prometheus/common/model

package model

// Sample is a sample pair associated with a metric. A single sample must either
// define Value or Histogram but not both. Histogram == nil implies the Value
// field is used, otherwise it should be ignored.
#Sample: _

// Samples is a sortable Sample slice. It implements sort.Interface.
#Samples: [...null | #Sample]

// SampleStream is a stream of Values belonging to an attached COWMetric.
#SampleStream: _

// Scalar is a scalar value evaluated at the set timestamp.
#Scalar: _

// String is a string value evaluated at the set timestamp.
#String: _

// Vector is basically only an alias for Samples, but the
// contract is that in a Vector, all Samples have the same timestamp.
#Vector: [...null | #Sample]

// Matrix is a list of time series.
#Matrix: [...null | #SampleStream]
