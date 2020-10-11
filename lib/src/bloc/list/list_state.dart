import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Model to keeps track of list state
///
/// [T] type of data element
///
/// [F] type of filter
class ListState<T, F> extends Equatable {
  // Different unique id trigger new state everytime
  final DateTime uuid = DateTime.now();
  // Actual data
  final List<T> items;
  // Filter object
  final F filter;
  // Indicate has reach end of file
  final bool hasReachedMax;
  // Optional data to store
  final dynamic extra;
  // Init flag
  final bool initialized;
  // Loading flag
  final bool loading;
  // Last error message
  final String error;

  ListState({
    @required this.items,
    this.hasReachedMax = false,
    this.filter,
    this.extra,
    this.initialized = false,
    this.loading = false,
    this.error = "",
  });

  ListState<T, F> copyWith({
    List<T> items,
    bool hasReachedMax,
    F filter,
    dynamic extra,
    bool loading = false,
    bool initialized = true,
    String error = "",
  }) {
    return ListState<T, F>(
      items: items ?? this.items,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax ?? true,
      filter: filter ?? this.filter,
      extra: extra ?? this.extra,
      loading: loading ?? false,
      initialized: initialized ?? true,
      error: error ?? "",
    );
  }

  @override
  List<Object> get props => [uuid];

  @override
  String toString() =>
      '${this.runtimeType} { uuid: $uuid, items: ${items.length}, hasReachedMax: $hasReachedMax, filter: $filter, extra: $extra, loading: $loading, initialized: $initialized, error: $error }';
}
