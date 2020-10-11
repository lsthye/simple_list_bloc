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
class SelectionStreamBuilder<T> extends StatelessWidget {
  final T target;
  final ListSelectionBloc<T> selectionBloc;
  final Widget Function(BuildContext, T, bool) builder;

  const SelectionStreamBuilder({
    Key key,
    @required this.builder,
    @required this.target,
    this.selectionBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ListSelectionBloc<T> bloc = selectionBloc ?? BlocProvider.of(context);
    bool has = bloc.selectedMap.containsKey(target);
    return StreamBuilder(
      key: Key("$target"),
      initialData: {"trigger": has, "hasTarget": has},
      builder: (context, snapshot) {
        return builder(context, target, snapshot.data["hasTarget"]);
      },
      stream: bloc.selectedItems.events.map((event) {
        bool trigger = false;
        bool hasTarget = false;
        if (event is AddItems<T>) {
          trigger = event.items.contains(target);
          hasTarget = true;
        } else if (event is RemoveItems<T>) {
          trigger = event.items.contains(target);
        }
        return {"trigger": trigger, "hasTarget": hasTarget};
      }).where((event) => event["trigger"]),
    );
  }
}
