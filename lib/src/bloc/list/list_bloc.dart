import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:simple_list_bloc/src/bloc/list/list_event.dart';
import 'package:simple_list_bloc/src/bloc/list/list_state.dart';
import 'package:rxdart/rxdart.dart';

/// A Generic list bloc, extends and implement fetch, add, remove
///
/// [T] type of data element
///
/// [F] type of filter
class ListBloc<T, F> extends Bloc<ListEvent, ListState<T, F>> {
  /// View count
  int _viewCount;

  /// Debounce duration
  int _debounce;

  /// Allow duplicate items
  bool _allowDuplicate;

  /// Print error message
  bool _debug;

  /// Events
  ListEvent? lastEvent;

  ListBloc({
    ListState<T, F>? state,
    int viewCount = 20,
    int debounce = 200,
    bool allowDuplicate = false,
    bool debug = false,
  })  : this._debounce = debounce,
        this._viewCount = viewCount,
        this._allowDuplicate = allowDuplicate,
        this._debug = debug,
        super(state ?? ListState<T, F>(items: []));

  @override
  void onEvent(ListEvent event) {
    super.onEvent(event);
    lastEvent = event;
  }

  /// Override this to handle add item
  @protected
  Future<List<T>> addItems(List<T> items) async => items;

  /// Override this to handle fetch
  @protected
  Future<List<T>> fetchItems(F? filter, int skip, int count) async => [];

  /// Override this to handle remove
  @protected
  Future<List<T>> removeItems(List<T> items) async => items;

  /// Override this to handle sort
  @protected
  Future<List<T>> sortItems(List<T> items, {List<T>? newItem}) async => items;

  /// Override this to handle custom event
  @protected
  Future<ListState<T, F>?> customEvent(ListEvent event) async {
    return state.copyWith(error: 'ListBloc Error: No implementation! - $runtimeType:[$event]');
  }

  @override
  Stream<Transition<ListEvent, ListState<T, F>>> transformEvents(
    Stream<ListEvent> events,
    TransitionFunction<ListEvent, ListState<T, F>> transitionFn,
  ) {
    return super.transformEvents(
      events.debounceTime(Duration(milliseconds: _debounce)),
      transitionFn,
    );
  }

  @override
  Stream<ListState<T, F>> mapEventToState(ListEvent event) async* {
    ListState<T, F>? r;
    try {
      if (event is PublishState<T, F>) {
        var items = await sortItems(event.state.items);
        r = event.state.copyWith(items: items);
      } else if (event is RefreshList) {
        if (event.clear) {
          r = state.copyWith(loading: true, items: [], hasReachedMax: false);
          Future.delayed(Duration(milliseconds: 10), () async {
            add(FetchItems<F>(filter: state.filter));
          });
        } else {
          var count = state.items.length;
          var reachedMax = (_viewCount == -1) ? true : state.hasReachedMax;
          r = state.copyWith(loading: true, hasReachedMax: reachedMax);
          Future.delayed(Duration(milliseconds: _debounce + 100), () async {
            r = await mapRefresh(event, max(count, _viewCount), reachedMax);
            add(PublishState<T, F>(r!));
          });
        }
      } else if (event is AddItems<T>) {
        r = await handleAddEvent(event);
      } else if (event is RemoveItems<T>) {
        r = await handleRemoveEvent(event);
      } else if (event is FetchItems<F>) {
        var max = state.hasReachedMax;
        if ((_viewCount < 0 || !max) || event.filter != state.filter) {
          if (event.clear) {
            yield state.copyWith(loading: true, items: []);
          } else {
            yield state.copyWith(loading: true);
          }
          r = await handleFetchEvent(event);
        }
      } else {
        r = await customEvent(event);
        if (r == null) {
          r = state.copyWith(error: "ListBloc Error: $runtimeType event not processed event = $event, state = $state");
        } else {
          var x = r;
          r = x.copyWith(
            items: List<T>.from(await sortItems(x.items)),
            loading: x.loading,
            error: x.error,
            initialized: x.initialized,
          );
        }
      }
      if (r != null) {
        yield r as ListState<T, F>;
      }
    } catch (e, stack) {
      if (_debug) print("ListBloc Error: [${event.runtimeType}: $r] $e, $stack");
      yield state.copyWith(error: '$e');
    }
  }

  /// Refresh list
  @protected
  Future<ListState<T, F>> mapRefresh(ListEvent event, int count, bool max) async {
    var items = await fetchItems(state.filter, 0, count);
    return state.copyWith(items: List<T>.from(await sortItems(items)), hasReachedMax: max, filter: state.filter);
  }

  /// Add new item to list
  @protected
  Future<ListState<T, F>> handleAddEvent(AddItems<T> event) async {
    var result = await addItems(event.items);
    if (result.length > 0) {
      List<T> filter = [];
      result.forEach((f) {
        bool exists = state.items.contains(f);
        if (event.replace && exists) {
          state.items.remove(f);
          exists = false;
        }
        if (!exists || _allowDuplicate) {
          filter.add(f);
        }
      });
      result = filter;
    }
    var items = await sortItems(state.items + result, newItem: result);
    return state.copyWith(items: List<T>.from(items));
  }

  /// Remove item from list
  @protected
  Future<ListState<T, F>> handleRemoveEvent(RemoveItems<T> event) async {
    var removed = await removeItems(event.items);
    List<T> result = removed.toList();
    if (result.length > 0) {
      for (var i = 0; i < result.length; i++) {
        state.items.remove(result[i]);
      }
    }
    var items = await sortItems(state.items);
    return state.copyWith(items: List<T>.from(items));
  }

  /// Fetch data
  @protected
  Future<ListState<T, F>> handleFetchEvent(FetchItems<F> event) async {
    final items = await fetchItems(event.filter, event.clear ? 0 : state.items.length, _viewCount);
    return state.copyWith(
      items: await sortItems(event.clear ? items : state.items + items),
      hasReachedMax: _viewCount == -1 || items.isEmpty
          ? true
          : event.clear
              ? false
              : state.hasReachedMax,
      filter: event.filter,
    );
  }

  /// Check if list contains target
  bool hasItem(T target) => state.items.contains(target);

  /// Fetch next page if not eof
  fetchNextPage() {
    if (!state.hasReachedMax) {
      add(FetchItems(filter: state.filter));
    }
  }
}
