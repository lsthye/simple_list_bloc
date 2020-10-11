import 'package:simple_list_bloc/simple_list_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

void main() {
  group('selection state', () {
    test('should be equal when same state', () {
      var first = SelectionState<int>();
      var second = first.copyWith();
      expect(first, equals(second));
    });
    test('should not be equal when property changed', () {
      var first = SelectionState<int>();
      var second = first.copyWith(maxSelection: 1);
      expect(first, isNot(equals(second)));
    });
    test('should not be equal when property changed 2', () {
      var first = SelectionState<int>();
      var second = first.copyWith(selecting: true);
      expect(first, isNot(equals(second)));
    });
  });

  group('list bloc', () {
    // ListSelectionBloc<int> bloc;
    // setUp(() => bloc = ListSelectionBloc<int>(SelectionState()));

    blocTest<ListSelectionBloc<int>, SelectionState>(
      'should change to selecting when call toggle while selecting = false',
      build: () => ListSelectionBloc<int>(SelectionState()),
      act: (bloc) => bloc.toggleSelection(),
      verify: (bloc) async {
        expect(bloc.state.selecting, equals(true));
      },
    );

    blocTest<ListSelectionBloc<int>, SelectionState>(
      'should change to selecting = false when call toggle while selecting = true',
      build: () => ListSelectionBloc<int>(SelectionState(selecting: true)),
      act: (bloc) => bloc.toggleSelection(),
      verify: (bloc) async {
        expect(bloc.state.selecting, equals(false));
      },
    );

    blocTest<ListSelectionBloc<int>, SelectionState>(
      'items should contains selected item',
      build: () => ListSelectionBloc<int>(SelectionState()),
      act: (bloc) async {
        bloc.toggleSelection();
        await Future.delayed(Duration(milliseconds: 100));
        bloc.selectItems([1, 2, 3]);
        await Future.delayed(Duration(milliseconds: 100));
      },
      verify: (bloc) async {
        expect(bloc.state.selecting, equals(true));
        expect(bloc.items, equals([1, 2, 3]));
      },
    );

    blocTest<ListSelectionBloc<int>, SelectionState>(
      'should change selecting back to false when clear selection',
      build: () => ListSelectionBloc<int>(SelectionState()),
      act: (bloc) async {
        bloc.toggleSelection();
        await Future.delayed(Duration(milliseconds: 100));
        bloc.selectItems([1, 2, 3]);
        await Future.delayed(Duration(milliseconds: 100));
        bloc.clearSelection();
      },
      verify: (bloc) async {
        expect(bloc.state.selecting, equals(false));
        expect(bloc.items.length, equals(0));
      },
    );

    blocTest<ListSelectionBloc<int>, SelectionState>(
      'should not change selecting back to false when clear selection with endSelectionMode = false',
      build: () => ListSelectionBloc<int>(SelectionState()),
      act: (bloc) async {
        bloc.toggleSelection();
        await Future.delayed(Duration(milliseconds: 100));
        bloc.selectItems([1, 2, 3]);
        await Future.delayed(Duration(milliseconds: 100));
        bloc.clearSelection(endSelectionMode: false);
        await Future.delayed(Duration(milliseconds: 100));
      },
      verify: (bloc) async {
        expect(bloc.state.selecting, equals(true));
        expect(bloc.items.length, equals(0));
      },
    );

    blocTest<ListSelectionBloc<int>, SelectionState>(
      'should remove unselected item from selections',
      build: () => ListSelectionBloc<int>(SelectionState()),
      act: (bloc) async {
        bloc.toggleSelection();
        await Future.delayed(Duration(milliseconds: 100));
        bloc.selectItems([1, 2, 3, 4, 5]);
        await Future.delayed(Duration(milliseconds: 100));
        bloc.unselectItems([2, 4]);
        await Future.delayed(Duration(milliseconds: 100));
      },
      verify: (bloc) async {
        expect(bloc.state.selecting, equals(true));
        expect(bloc.items, equals([1, 3, 5]));
      },
    );

    blocTest<ListSelectionBloc<int>, SelectionState>(
      'should not select more then max selection of items',
      build: () => ListSelectionBloc<int>(SelectionState(maxSelection: 3)),
      act: (bloc) async {
        bloc.toggleSelection();
        await Future.delayed(Duration(milliseconds: 100));
        bloc.selectItems([1, 2, 3, 4, 5]);
        await Future.delayed(Duration(milliseconds: 100));
        bloc.unselectItems([1, 2]);
        await Future.delayed(Duration(milliseconds: 100));
        bloc.toggleItem(7);
        await Future.delayed(Duration(milliseconds: 100));
        bloc.selectItems([6]);
        await Future.delayed(Duration(milliseconds: 100));
        bloc.toggleItem(3);
        await Future.delayed(Duration(milliseconds: 100));
      },
      verify: (bloc) async {
        expect(bloc.state.selecting, equals(true));
        expect(bloc.items, equals([7, 6]));
      },
    );

    blocTest<ListSelectionBloc<int>, SelectionState>(
      'should set selecting to false when call start bulk select with null target',
      build: () => ListSelectionBloc<int>(SelectionState()),
      act: (bloc) async {
        bloc.toggleSelection();
        await Future.delayed(Duration(milliseconds: 100));
        bloc.selectItems([1, 2, 3, 4, 5]);
        await Future.delayed(Duration(milliseconds: 100));
        bloc.startBulkSelect(null);
        await Future.delayed(Duration(milliseconds: 100));
      },
      verify: (bloc) async {
        expect(bloc.items, equals([1, 2, 3, 4, 5]));
        expect(bloc.state.selecting, equals(false));
      },
    );

    blocTest<ListSelectionBloc<int>, SelectionState>(
      'should set selecting to false when call start bulk select with null target',
      build: () => ListSelectionBloc<int>(SelectionState()),
      act: (bloc) async {
        bloc.toggleSelection();
        await Future.delayed(Duration(milliseconds: 100));
        bloc.selectItems([1, 2, 3, 4, 5]);
        await Future.delayed(Duration(milliseconds: 100));
        bloc.endMultiSelect(null, []);
        await Future.delayed(Duration(milliseconds: 100));
      },
      verify: (bloc) async {
        expect(bloc.items, equals([1, 2, 3, 4, 5]));
        expect(bloc.state.selecting, equals(false));
      },
    );

    blocTest<ListSelectionBloc<int>, SelectionState>(
      'should update state with start select target without selecting anything',
      build: () => ListSelectionBloc<int>(SelectionState()),
      act: (bloc) async {
        bloc.startBulkSelect(3);
        await Future.delayed(Duration(milliseconds: 100));
      },
      verify: (bloc) async {
        expect(bloc.items.length, equals(0));
        expect(bloc.state.selecting, equals(true));
        expect(bloc.state.startItem, equals(3));
      },
    );

    blocTest<ListSelectionBloc<int>, SelectionState>(
      'should able to select as normal even has start select target',
      build: () => ListSelectionBloc<int>(SelectionState()),
      act: (bloc) async {
        bloc.startBulkSelect(3);
        await Future.delayed(Duration(milliseconds: 100));
        bloc.selectItems([1, 2, 3, 4, 5]);
        await Future.delayed(Duration(milliseconds: 100));
      },
      verify: (bloc) async {
        expect(bloc.items, equals([1, 2, 3, 4, 5]));
        expect(bloc.state.selecting, equals(true));
        expect(bloc.state.startItem, equals(3));
      },
    );

    blocTest<ListSelectionBloc<int>, SelectionState>(
      'should select all items between start and end',
      build: () => ListSelectionBloc<int>(SelectionState()),
      act: (bloc) async {
        bloc.startBulkSelect(3);
        await Future.delayed(Duration(milliseconds: 100));
        bloc.endMultiSelect(7, [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]);
        await Future.delayed(Duration(milliseconds: 100));
      },
      verify: (bloc) async {
        expect(bloc.items, equals([3, 4, 5, 6, 7]));
        expect(bloc.state.selecting, equals(true));
        expect(bloc.state.startItem, equals(3));
      },
    );

    blocTest<ListSelectionBloc<int>, SelectionState>(
      'should select all items between start and end even it\s reverse order',
      build: () => ListSelectionBloc<int>(SelectionState()),
      act: (bloc) async {
        bloc.startBulkSelect(7);
        await Future.delayed(Duration(milliseconds: 100));
        bloc.endMultiSelect(3, [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]);
        await Future.delayed(Duration(milliseconds: 100));
      },
      verify: (bloc) async {
        expect(bloc.items, equals([3, 4, 5, 6, 7]));
        expect(bloc.state.selecting, equals(true));
        expect(bloc.state.startItem, equals(7));
      },
    );

    blocTest<ListSelectionBloc<int>, SelectionState>(
      'should bulk select should append to current list without duplicate',
      build: () => ListSelectionBloc<int>(SelectionState()),
      act: (bloc) async {
        bloc.startBulkSelect(3);
        await Future.delayed(Duration(milliseconds: 100));
        bloc.selectItems([1, 2, 3, 4, 5]);
        await Future.delayed(Duration(milliseconds: 100));
        bloc.endMultiSelect(7, [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]);
        await Future.delayed(Duration(milliseconds: 100));
      },
      verify: (bloc) async {
        expect(bloc.items, equals([1, 2, 3, 4, 5, 6, 7]));
        expect(bloc.state.selecting, equals(true));
        expect(bloc.state.startItem, equals(3));
      },
    );
  });
}
