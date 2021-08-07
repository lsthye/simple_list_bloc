import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_list_bloc/simple_list_bloc.dart';
import 'package:simple_list_bloc/src/bloc/list/list_selection_bloc.dart';

/// Streambuilder trigger when [target] was added or remove from selection
///
/// [target] the target item
///
/// [selectionBloc] selection bloc to monitor
///
/// [builder] build when target was added/removed
class SelectionStreamBuilder<T> extends BlocBuilderBase<ListSelectionBloc, SelectionState> {
  final T target;
  final ListSelectionBloc<T>? selectionBloc;
  final Widget Function(BuildContext, ListSelectionBloc<T>?, T, bool) builder;

  const SelectionStreamBuilder({
    Key? key,
    required this.builder,
    required this.target,
    required this.selectionBloc,
  }) : super(key: key, bloc: selectionBloc);

  @override
  get buildWhen => (a, b) => a.selectedItems.containsKey(target) != b.selectedItems.containsKey(target);

  @override
  Widget build(BuildContext context, SelectionState state) {
    return builder(context, selectionBloc, target, state.selectedItems.containsKey(target));
  }
}
