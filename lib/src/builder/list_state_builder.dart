import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_list_bloc/src/bloc/list/list_bloc.dart';
import 'package:simple_list_bloc/src/bloc/list/list_event.dart';
import 'package:simple_list_bloc/src/bloc/list/list_state.dart';

/// build widget according to list bloc's state
///
/// [onSuccess] when bloc has been loaded without any error
///
/// [onInit] when bloc first init
///
/// [onLoading] when bloc is refreshing the whole list
///
/// [onEmpty] when bloc has loaded but it's empty
///
/// [onError] when bloc has error message
class ListStateBuilder<B extends ListBloc> extends BlocBuilderBase<B, ListState> {
  final B? bloc;
  final Widget Function(BuildContext) onSuccess;
  final Widget Function(BuildContext)? onInit;
  final Widget Function(BuildContext)? onEmpty;
  final Widget Function(BuildContext, bool)? onLoading;
  final Widget Function(BuildContext, ListEvent?, String, bool)? onError;
  final BlocBuilderCondition<ListState>? condition;

  ListStateBuilder({
    Key? key,
    this.bloc,
    required this.onSuccess,
    this.onInit,
    this.onLoading,
    this.onEmpty,
    this.onError,
    this.condition,
  }) : super(key: key, bloc: bloc, buildWhen: condition);

  @override
  Widget build(BuildContext context, ListState state) {
    if (state.items.length == 0) {
      if (!state.initialized && onInit != null) {
        return onInit!(context);
      } else if (state.loading && onLoading != null) {
        return onLoading!(context, true);
      } else if (state.error.isNotEmpty && onError != null) {
        return onError!(context, bloc!.lastEvent, state.error, true);
      } else if (onEmpty != null) {
        return onEmpty!(context);
      } else {
        return SizedBox();
      }
    } else {
      return Column(children: [
        Expanded(child: onSuccess(context)),
        if (state.loading && onLoading != null) onLoading!(context, false),
        if (state.error.isNotEmpty && onError != null) onError!(context, bloc!.lastEvent, state.error, false),
      ]);
    }
  }
}
