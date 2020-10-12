import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:simple_list_bloc/simple_list_bloc.dart';
import 'package:simple_list_bloc/src/bloc/list/list_bloc.dart';

/// Cubit to control list's selection
class ListSelectionBloc<T> extends Cubit<SelectionState<T>> {
  /// bloc to hold selected items
  final ListBloc<T, String> selectedItems = ListBloc(debounce: 0);

  /// map for faster lookup for selected items
  final Map<T, bool> selectedMap = {};

  /// subscription listen to slecteditems bloc and update selectedmap
  StreamSubscription streamSubscription;

  ListSelectionBloc(SelectionState<T> state) : super(state) {
    streamSubscription = selectedItems.listen((state) {
      selectedMap.clear();
      state.items.forEach((element) {
        selectedMap[element] = true;
      });
    });
  }

  /// get list of selected items
  List<T> get items => selectedItems.state.items;

  @override
  Future<void> close() {
    streamSubscription.cancel();
    selectedItems.close();
    return super.close();
  }

  /// toggle selection mode
  void toggleSelection() {
    emit(state.copyWith(selecting: !state.selecting, maxSelection: state.maxSelection));
  }

  /// set starting flag for bulk selection, if target = null will disable selection mode
  ///
  /// [target] starting flag for bulk select
  void startBulkSelect(T target) {
    if (target != null) {
      emit(state.copyWith(
        selecting: true,
        startItem: target,
        bulk: true,
        maxSelection: state.maxSelection,
      ));
    } else {
      emit(state.copyWith(maxSelection: state.maxSelection));
    }
  }

  /// set ending flag for bulk selection, if target/selectionBloc = null will disable selection mode
  ///
  /// [endTarget] ending flag for bulk select
  ///
  /// [list] all item list
  void endMultiSelect(T endTarget, List<T> list) {
    if (endTarget == null) {
      emit(state.copyWith(maxSelection: state.maxSelection));
    } else {
      List<T> selected = [];
      var startTarget = state.startItem;
      int found = 0;
      for (var i = 0; i < list.length; i++) {
        var f = list[i];
        if (f == startTarget || f == endTarget) {
          found++;
        }
        if (1 <= found && found <= 2) {
          if (!selectedMap.containsKey(f)) {
            selected.add(f);
          }
        }
        if (found >= 2) {
          break;
        }
      }
      selectItems(selected);
    }
  }

  /// clear all selection and end selection mode
  void clearSelection({bool endSelectionMode = true}) {
    if (selectedItems != null) {
      selectedItems.add(RemoveItems(selectedItems.state.items));
    }
    if (endSelectionMode) {
      emit(state.copyWith(maxSelection: state.maxSelection));
    }
  }

  /// select item if not exist, unselect if exist
  void toggleItem(T item) {
    if (selectedItems != null && item != null) {
      if (!selectedItems.state.items.contains(item)) {
        selectItems([item]);
      } else {
        unselectItems([item]);
      }
    }
  }

  /// add items to selection
  void selectItems(List<T> items) {
    if (selectedItems != null) {
      List<T> toAdd = items.toList();
      if (state.maxSelection > 0) {
        while ((toAdd.length + selectedItems.state.items.length) > state.maxSelection && toAdd.length > 0) {
          toAdd.removeLast();
        }
      }
      if (toAdd.length > 0) selectedItems.add(AddItems(toAdd));
    }
  }

  /// remove items from selection
  void unselectItems(List<T> items) {
    if (selectedItems != null && items.length > 0) {
      selectedItems.add(RemoveItems(items));
    }
  }
}

/// Selection's state
///
/// [maxSelection] limit number of items can be selected
///
/// [selecting] is selection enabled
///
/// [bulk] is bulk select mode enabled
///
/// [startItem] starting flag for bulk select
class SelectionState<T> extends Equatable {
  final int maxSelection;
  final bool selecting;
  final bool bulk;
  final T startItem;

  SelectionState({
    this.maxSelection = -1,
    this.selecting = false,
    this.bulk = false,
    this.startItem,
  });

  SelectionState<T> copyWith({
    int maxSelection = -1,
    bool selecting = false,
    bool bulk = false,
    T startItem,
  }) {
    return SelectionState<T>(
      maxSelection: maxSelection ?? -1,
      selecting: selecting ?? false,
      bulk: bulk ?? false,
      startItem: startItem,
    );
  }

  @override
  List<Object> get props => [maxSelection, selecting, bulk, startItem];
}
