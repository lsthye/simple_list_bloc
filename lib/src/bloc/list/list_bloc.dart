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

  /// Print debug message
  bool _debug;

  /// Events
  BehaviorSubject<ListEvent> _events = BehaviorSubject.seeded(null);
  Stream<ListEvent> get events => _events.stream;
  ListEvent get lastEvent => _events.value;

  ListBloc({
    ListState<T, F> state,
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
  Future<void> close() {
    _events.close();
    return super.close();
  }

  @override
  void onEvent(ListEvent event) {
    super.onEvent(event);
    _events.sink.add(event);
  }

  /// Override this to handle add item
  @protected
  Future<List<T>> addItems(List<T> items) async => items;

  /// Override this to handle fetch
  @protected
  Future<List<T>> fetchItems(F filter, int skip, int count) async => [];

  /// Override this to handle remove
  @protected
  Future<List<T>> removeItems(List<T> items) async => items;

  /// Override this to handle sort
  @protected
  Future<List<T>> sortItems(List<T> items, {List<T> newItem}) async => items;

  /// Override this to handle custom event
  @protected
  Future<ListState<T, F>> customEvent(ListState<T, F> currentState, ListEvent event) async {
    return currentState.copyWith(error: 'ListBloc Error: No implementation! - $runtimeType:[$event]');
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
    ListState<T, F> r;
    try {
      if (event is PublishState) {
        var items = await sortItems(event.state.items);
        r = event.state.copyWith(items: items);
      } else if (event is RefreshList) {
        if (event.clear) {
          r = state.copyWith(loading: true, items: []);
          Future.delayed(Duration(milliseconds: 10), () async {
            add(FetchItems<F>(filter: state.filter));
          });
        } else {
          var count = state.items.length;
          var reachedMax = (_viewCount == -1) ? true : state.hasReachedMax;
          r = state.copyWith(loading: true, hasReachedMax: reachedMax);
          Future.delayed(Duration(milliseconds: _debounce + 100), () async {
            r = await mapRefresh(state, event, max(count, _viewCount), reachedMax);
            add(PublishState(r));
          });
        }
      } else if (event is AddItems<T>) {
        r = await handleAddEvent(state, event);
      } else if (event is RemoveItems<T>) {
        r = await handleRemoveEvent(state, event);
      } else if (event is FetchItems<F>) {
        var max = state?.hasReachedMax ?? true;
        if ((_viewCount < 0 || !max) || event.filter != state.filter) {
          if (event.clear) {
            yield state.copyWith(loading: true, items: []);
          } else {
            yield state.copyWith(loading: true);
          }
          r = await handleFetchEvent(state, event);
        }
      } else {
        r = await customEvent(state, event);
        if (r == null) {
          r = state.copyWith(error: "ListBloc Error: $runtimeType event not processed event = $event, state = $state");
        } else {
          var x = r;
          r = x.copyWith(
            items: List<T>() + await sortItems(x.items),
            loading: x.loading,
            error: x.error,
            initialized: x.initialized,
          );
        }
      }
      if (r != null) {
        yield r;
      }
    } catch (e, stack) {
      if (_debug) print("ListBloc Error: [${event.runtimeType}: $r] $e, $stack");
      yield state.copyWith(error: '$e');
    }
  }

  /// Refresh list
  @protected
  Future<ListState<T, F>> mapRefresh(ListState<T, F> currentState, ListEvent event, int count, bool max) async {
    var items = await fetchItems(currentState?.filter, 0, count);
    return currentState.copyWith(
      items: List<T>() + await sortItems(items),
      hasReachedMax: max,
      filter: currentState?.filter,
    );
  }

  /// Add new item to list
  @protected
  Future<ListState<T, F>> handleAddEvent(ListState<T, F> state, AddItems<T> event) async {
    var result = await addItems(event.items);
    if (result != null && result.length > 0) {
      var filter = List<T>();
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
    return state.copyWith(items: List<T>() + items);
  }

  /// Remove item from list
  @protected
  Future<ListState<T, F>> handleRemoveEvent(ListState<T, F> state, RemoveItems<T> event) async {
    var result = List<T>() + await removeItems(event.items);
    if (result != null && result.length > 0) {
      for (var i = 0; i < result.length; i++) {
        state.items.remove(result[i]);
      }
    }
    var items = await sortItems(state.items);
    return state.copyWith(items: List<T>() + items);
  }

  /// Fetch data
  @protected
  Future<ListState<T, F>> handleFetchEvent(ListState<T, F> rState, FetchItems<F> event) async {
    final items = await fetchItems(event.filter, event.clear ? 0 : rState.items.length, _viewCount);
    return rState.copyWith(
      items: event.clear ? items : rState.items + items,
      hasReachedMax: _viewCount == -1 || items.isEmpty
          ? true
          : event.clear
              ? false
              : rState.hasReachedMax,
      filter: event.filter,
    );
  }

  fetchNextPage() {
    if (!state.hasReachedMax) {
      add(FetchItems(filter: state.filter));
    }
  }
}
