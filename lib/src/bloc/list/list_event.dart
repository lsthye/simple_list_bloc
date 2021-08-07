import 'package:equatable/equatable.dart';
import 'package:simple_list_bloc/src/bloc/list/list_state.dart';

/// Base list event
abstract class ListEvent extends Equatable {}

/// Publish/replace current state
///
/// [T] type of data element
///
/// [F] type of filter
class PublishState<T, F> extends ListEvent {
  final ListState<T, F> state;

  PublishState(this.state);

  @override
  String toString() => '${this.runtimeType} state = ${state.toString()}';

  @override
  List<Object> get props => [state];
}

/// Refresh list
class RefreshList extends ListEvent {
  // clear list and fetch from begining
  final bool clear;

  RefreshList({this.clear = false});

  @override
  String toString() => '${this.runtimeType}';

  @override
  List<Object> get props => [DateTime.now()];
}

/// Add items
///
/// [T] type of data element
class AddItems<T> extends ListEvent {
  // items to add
  final List<T> items;
  // replace with new item if already exists
  final bool replace;

  AddItems(this.items, {this.replace = true});

  @override
  String toString() => '${this.runtimeType} { items: ${items.toString()} }';

  @override
  List<Object> get props => [items];
}

/// Remove items from list
///
/// [T] type of data element
class RemoveItems<T> extends ListEvent {
  // items to remove
  final List<T> items;

  RemoveItems(this.items);

  @override
  String toString() => '${this.runtimeType} { items: ${items.toString()} }';

  @override
  List<Object> get props => [items];
}

/// Fetch items
///
/// [F] type of filter
class FetchItems<F> extends ListEvent {
  // filter
  final F? filter;
  // clear and fetch from begining
  final bool clear;

  FetchItems({this.filter, this.clear = false});

  @override
  String toString() => '${this.runtimeType} { filter: ${filter.toString()} }';

  @override
  List<Object> get props => [DateTime.now()];
}
