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
class ListStateBuilder<B extends ListBloc> extends StatefulWidget {
  final B bloc;
  final Widget Function(BuildContext) onSuccess;
  final Widget Function(BuildContext) onInit;
  final Widget Function(BuildContext) onEmpty;
  final Widget Function(BuildContext, bool) onLoading;
  final Function(BuildContext, ListEvent, String, bool) onError;
  final BlocBuilderCondition<ListState> condition;

  ListStateBuilder({
    Key key,
    this.bloc,
    @required this.onSuccess,
    this.onInit,
    this.onLoading,
    this.onEmpty,
    this.onError,
    this.condition,
  }) : super(key: key);

  @override
  _ListStateBuilderState createState() => _ListStateBuilderState();
}

class _ListStateBuilderState<B extends ListBloc> extends State<ListStateBuilder<B>> {
  Widget cache;
  int lastCacheItemCount = 0;

  @override
  Widget build(BuildContext context) {
    B bloc = widget.bloc ?? BlocProvider.of<B>(context);
    return BlocBuilder<B, ListState>(
      cubit: bloc,
      builder: (context, state) {
        if (!state.initialized && widget.onInit != null) {
          return widget.onInit(context) ?? SizedBox();
        } else if (state.loading && widget.onLoading != null) {
          var child = widget.onLoading(context, state.items.length == 0) ?? SizedBox();
          if (state.items.length == 0) {
            return child;
          } else {
            return Column(children: [Expanded(child: getChild(context)), child]);
          }
        } else if (state.error != null && state.error.isNotEmpty && widget.onError != null) {
          var child =
              widget.onError(context, widget.bloc.lastEvent, state.error, state.items.length == 0) ?? SizedBox();
          if (state.items.length == 0) {
            return child;
          } else {
            return Column(children: [Expanded(child: getChild(context)), child]);
          }
        } else if (state.items != null) {
          if (state.items.length == 0 && widget.onEmpty != null) {
            return widget.onEmpty(context) ?? SizedBox();
          }
          return getChild(context);
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget getChild(BuildContext context) {
    if (cache == null || lastCacheItemCount != widget.bloc.state.items.length) {
      cache = widget.onSuccess(context);
      lastCacheItemCount = widget.bloc.state.items.length;
    }
    return cache;
  }
}
