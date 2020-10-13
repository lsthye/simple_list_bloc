import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

/// Cubit to control list's selection
class ListSelectionBloc<T> extends Cubit<SelectionState<T>> {
  ListSelectionBloc({SelectionState<T> state}) : super(state ?? SelectionState<T>());

  /// get list of selected items
  List<T> get items => state.selectedItems.keys.toList();

  /// toggle selection mode
  void toggleSelection() {
    emit(state.copyWith(selecting: !state.selecting));
  }

  /// set starting flag for bulk selection
  ///
  /// [target] starting flag for bulk select
  void startBulkSelect(T target) {
    emit(state.copyWith(
      selecting: true,
      startItem: target,
      bulk: true,
    ));
  }

  /// set ending flag for bulk selection, if target/list = null will disable selection mode
  ///
  /// [target] ending flag for bulk select
  ///
  /// [list] all item list
  void endMultiSelect({T target, List<T> list}) {
    if (target == null || list == null) {
      emit(state.copyWith(selecting: false));
    } else {
      List<T> selected = [];
      var startTarget = state.startItem;
      int found = 0;
      for (var i = 0; i < list.length; i++) {
        var f = list[i];
        if (f == startTarget || f == target) {
          found++;
        }
        if (1 <= found && found <= 2) {
          if (!state.selectedItems.containsKey(f)) {
            selected.add(f);
          }
        }
        if (found >= 2) {
          break;
        }
      }
      _selectItems(selected);
    }
  }

  /// clear all selection and end selection mode
  void clearSelection({bool endSelectionMode = true}) {
    if (endSelectionMode) {
      emit(state.copyWithMap(selecting: false, selectedItems: {}));
    } else {
      emit(state.copyWithMap(selectedItems: {}));
    }
  }

  /// select item if not exist, unselect if exist
  void toggleItem(T item) {
    Map<T, bool> tmp = Map.from(state.selectedItems);
    if (state.selectedItems.containsKey(item)) {
      tmp.remove(item);
    } else {
      tmp[item] = true;
    }
    emit(state.copyWithMap(selectedItems: tmp));
  }

  /// add items to selection
  void selectItems(List<T> items) => _selectItems(items, startItem: state.startItem);

  /// add items to selection
  void _selectItems(List<T> items, {T startItem}) {
    List<T> toAdd = items.toList();
    if (state.maxSelection > 0) {
      while ((toAdd.length + state.selectedItems.length) > state.maxSelection && toAdd.length > 0) {
        toAdd.removeLast();
      }
    }
    if (toAdd.length > 0) {
      Map<T, bool> tmp = Map.from(state.selectedItems);
      toAdd.forEach((element) {
        tmp[element] = true;
      });
      emit(state.copyWithMap(selectedItems: tmp, startItem: startItem));
    }
  }

  /// remove items from selection
  void unselectItems(List<T> items) {
    Map<T, bool> tmp = Map.from(state.selectedItems);
    tmp.removeWhere((key, value) => items.contains(key));
    emit(state.copyWithMap(selectedItems: tmp));
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
  final Map<T, bool> selectedItems;

  SelectionState({
    this.maxSelection = -1,
    this.selecting = false,
    this.bulk = false,
    this.startItem,
    this.selectedItems = const {},
  });

  SelectionState<T> copyWith({
    int maxSelection,
    bool selecting,
    bool bulk,
    T startItem,
  }) {
    return SelectionState<T>(
      maxSelection: maxSelection ?? this.maxSelection ?? -1,
      selecting: selecting ?? this.selecting ?? false,
      bulk: bulk ?? this.bulk ?? false,
      startItem: startItem,
      selectedItems: selectedItems,
    );
  }

  SelectionState<T> copyWithMap({
    int maxSelection,
    bool selecting,
    bool bulk,
    T startItem,
    Map<T, bool> selectedItems,
  }) {
    return SelectionState<T>(
      maxSelection: maxSelection ?? this.maxSelection ?? -1,
      selecting: selecting ?? this.selecting ?? false,
      bulk: bulk ?? this.bulk ?? false,
      startItem: startItem,
      selectedItems: Map.unmodifiable(selectedItems),
    );
  }

  @override
  List<Object> get props => [maxSelection, selecting, bulk, startItem, selectedItems];
}
