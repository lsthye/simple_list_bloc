import 'package:bloc_test/bloc_test.dart';
import 'package:simple_list_bloc/src/bloc/list/list_bloc.dart';
import 'package:simple_list_bloc/src/bloc/list/list_event.dart';
import 'package:simple_list_bloc/src/bloc/list/list_state.dart';
import 'package:flutter_test/flutter_test.dart';

class SortIntListBloc extends ListBloc<int, bool> {
  SortIntListBloc(ListState<int, bool> state) : super(state: state, debounce: 0);

  @override
  Future<List<int>> sortItems(List<int> items, {List<int> newItem}) {
    items.sort();
    return super.sortItems(items, newItem: newItem);
  }

  @override
  Future<List<int>> fetchItems(bool filter, int skip, int count) async {
    List<int> result = [];
    for (var i = 0; i < count; i++) {
      result.add(skip + i);
    }
    return result;
  }

  @override
  Future<ListState<int, bool>> customEvent(ListState<int, bool> currentState, ListEvent event) async {
    if (event is ThrowErrorEvent) {
      throw "Intended Error";
    }
    if (event is NullEvent) {
      return null;
    }
    return super.customEvent(currentState, event);
  }
}

class IntListBloc extends ListBloc<int, bool> {
  IntListBloc(ListState<int, bool> state) : super(state: state, debounce: 0);
}

class CustomEvent extends ListEvent {
  @override
  List<Object> get props => [""];
}

class ThrowErrorEvent extends ListEvent {
  @override
  List<Object> get props => [""];
}

class NullEvent extends ListEvent {
  @override
  List<Object> get props => [""];
}

void main() {
  SortIntListBloc bloc;
  setUp(() => bloc = SortIntListBloc(ListState(items: [], initialized: false)));
  group('list bloc', () {
    test('should start with uninitialized state', () {
      expect(bloc.state.initialized, equals(false));
      expect(bloc.state.loading, equals(false));
      expect(bloc.lastEvent, equals(null));
    });

    blocTest<SortIntListBloc, ListState>(
      'should changed to initialized state after first event',
      build: () => SortIntListBloc(ListState(items: [])),
      act: (bloc) => bloc.add(FetchItems(filter: false)),
      verify: (bloc) async {
        expect(bloc.state.initialized, equals(true));
        expect(bloc.state.items.length, equals(20));
        expect(bloc.state.hasReachedMax, equals(false));
        expect("${bloc.lastEvent.runtimeType}", equals("${FetchItems(filter: false).runtimeType}"));
      },
    );

    blocTest<SortIntListBloc, ListState>(
      'should append list',
      build: () => SortIntListBloc(ListState(items: [5, 6, 7])),
      act: (bloc) => bloc.add(FetchItems(filter: false)),
      verify: (bloc) async {
        expect(bloc.state.initialized, equals(true));
        expect(bloc.state.items.length, equals(23));
        expect(bloc.state.hasReachedMax, equals(false));
        expect("${bloc.lastEvent.runtimeType}", equals("${FetchItems(filter: false).runtimeType}"));
      },
    );

    blocTest<SortIntListBloc, ListState>(
      'should append list when call fetchnextpage',
      build: () => SortIntListBloc(ListState(items: [5, 6, 7])),
      act: (bloc) => bloc.fetchNextPage(),
      verify: (bloc) async {
        expect(bloc.state.initialized, equals(true));
        expect(bloc.state.items.length, equals(23));
        expect(bloc.state.hasReachedMax, equals(false));
        expect("${bloc.lastEvent.runtimeType}", equals("${FetchItems(filter: false).runtimeType}"));
      },
    );

    blocTest<SortIntListBloc, ListState>(
      'should not append list when fetch items with clear flag',
      build: () => SortIntListBloc(ListState(items: [5, 6, 7])),
      act: (bloc) => bloc.add(FetchItems(filter: false, clear: true)),
      verify: (bloc) async {
        expect(bloc.state.initialized, equals(true));
        expect(bloc.state.items.length, equals(20));
        expect(bloc.state.hasReachedMax, equals(false));
        expect("${bloc.lastEvent.runtimeType}", equals("${FetchItems(filter: false).runtimeType}"));
      },
    );

    blocTest<SortIntListBloc, ListState>(
      'should change state to loading before refresh',
      build: () => SortIntListBloc(ListState(items: [1, 2, 3, 4, 5])),
      act: (bloc) => bloc.add(RefreshList(clear: true)),
      verify: (bloc) async {
        expect(bloc.state.initialized, equals(true));
        expect(bloc.state.items.length, equals(0));
        expect(bloc.state.loading, equals(true));
        expect("${bloc.lastEvent.runtimeType}", equals("${RefreshList().runtimeType}"));
      },
    );

    blocTest<SortIntListBloc, ListState>(
      'should not clear items when refresh',
      build: () => SortIntListBloc(ListState(items: [1, 2, 3, 4, 5])),
      act: (bloc) => bloc.add(RefreshList()),
      verify: (bloc) async {
        expect(bloc.state.initialized, equals(true));
        expect(bloc.state.items.length, equals(5));
        expect(bloc.state.loading, equals(true));
        expect("${bloc.lastEvent.runtimeType}", equals("${RefreshList().runtimeType}"));
      },
    );

    blocTest<SortIntListBloc, ListState>(
      'initialed items should be cleared after refresh',
      build: () => SortIntListBloc(ListState(items: [1, 2, 3, 4, 5])),
      act: (bloc) => bloc.add(RefreshList()),
      skip: 1,
      wait: Duration(milliseconds: 150),
      verify: (bloc) async {
        expect(bloc.state.initialized, equals(true));
        expect(bloc.state.loading, equals(false));
        expect(bloc.state.items.length, equals(20));
        expect("${bloc.lastEvent.runtimeType}", equals("${PublishState<int, bool>(null).runtimeType}"));
      },
    );

    blocTest<SortIntListBloc, ListState>(
      'should auto sort items when publish state',
      build: () => SortIntListBloc(ListState(items: [])),
      act: (bloc) => bloc.add(PublishState<int, bool>(ListState(items: [1, 3, 2, 5]))),
      verify: (bloc) {
        expect(bloc.state.items, equals([1, 2, 3, 5]));
        expect("${bloc.lastEvent.runtimeType}", equals("${PublishState<int, bool>(null).runtimeType}"));
      },
    );

    blocTest<IntListBloc, ListState>(
      'should not auto sort items',
      build: () => IntListBloc(ListState(items: [])),
      act: (bloc) {
        bloc.add(PublishState<int, bool>(ListState(items: [1, 3, 2, 5])));
      },
      verify: (bloc) async {
        expect(bloc.state.items, equals([1, 3, 2, 5]));
        expect("${bloc.lastEvent.runtimeType}", equals("${PublishState<int, bool>(null).runtimeType}"));
      },
    );

    blocTest<ListBloc, ListState>(
      'should not add duplicate items',
      build: () => ListBloc(state: ListState(items: [1, 2, 3]), debounce: 0),
      act: (bloc) => bloc.add(AddItems([3, 4, 5], replace: false)),
      verify: (bloc) async {
        expect(bloc.state.items, equals([1, 2, 3, 4, 5]));
        expect("${bloc.lastEvent.runtimeType}", equals("${AddItems([3, 4, 5]).runtimeType}"));
      },
    );

    blocTest<ListBloc, ListState>(
      'should not have duplicate when add item with replace flag',
      build: () => ListBloc(state: ListState(items: [1, 2, 3]), debounce: 0, allowDuplicate: true),
      act: (bloc) => bloc.add(AddItems([3, 4, 5], replace: true)),
      verify: (bloc) async {
        expect(bloc.state.items, equals([1, 2, 3, 4, 5]));
        expect("${bloc.lastEvent.runtimeType}", equals("${AddItems([3, 4, 5]).runtimeType}"));
      },
    );

    blocTest<ListBloc, ListState>(
      'should add duplicate items',
      build: () => ListBloc(state: ListState(items: [1, 2, 3]), debounce: 0, allowDuplicate: true),
      act: (bloc) => bloc.add(AddItems([3, 4, 5], replace: false)),
      verify: (bloc) async {
        expect(bloc.state.items, equals([1, 2, 3, 3, 4, 5]));
        expect("${bloc.lastEvent.runtimeType}", equals("${AddItems([3, 4, 5]).runtimeType}"));
      },
    );

    blocTest<ListBloc, ListState>(
      'should remove items',
      build: () => ListBloc(state: ListState(items: [1, 2, 3, 4, 5]), debounce: 0, allowDuplicate: true),
      act: (bloc) => bloc.add(RemoveItems([3, 5, 6])),
      verify: (bloc) async {
        expect(bloc.state.items, equals([1, 2, 4]));
        expect("${bloc.lastEvent.runtimeType}", equals("${RemoveItems([3, 5, 6]).runtimeType}"));
      },
    );

    blocTest<ListBloc, ListState>(
      'should throw error when event not implemented',
      build: () => ListBloc(debounce: 0),
      act: (bloc) => bloc.add(ThrowErrorEvent()),
      verify: (bloc) async {
        expect(bloc.state.error,
            equals('ListBloc Error: No implementation! - ListBloc<dynamic, dynamic>:[ThrowErrorEvent]'));
        expect("${bloc.lastEvent.runtimeType}", equals("${ThrowErrorEvent().runtimeType}"));
      },
    );

    blocTest<SortIntListBloc, ListState>(
      'should throw error when event not implemented',
      build: () => SortIntListBloc(ListState(items: [])),
      act: (bloc) => bloc.add(ThrowErrorEvent()),
      verify: (bloc) async {
        expect(bloc.state.error, equals('Intended Error'));
        expect("${bloc.lastEvent.runtimeType}", equals("${ThrowErrorEvent().runtimeType}"));
      },
    );

    blocTest<SortIntListBloc, ListState>(
      'should return last state with error message when return null state in custom event',
      build: () => SortIntListBloc(ListState(items: [])),
      act: (bloc) => bloc.add(NullEvent()),
      verify: (bloc) async {
        expect(bloc.state.error.isNotEmpty, equals(true));
        expect("${bloc.lastEvent.runtimeType}", equals("${NullEvent().runtimeType}"));
      },
    );

    blocTest<ListBloc, ListState>(
      'debounce should only handle the last event',
      build: () => ListBloc(debounce: 80),
      act: (bloc) {
        bloc.add(AddItems([0]));
        bloc.add(AddItems([1]));
        bloc.add(AddItems([2]));
      },
      wait: Duration(milliseconds: 100),
      verify: (bloc) async {
        expect(bloc.state.items, equals([2]));
        expect("${bloc.lastEvent.runtimeType}", equals("${AddItems([2]).runtimeType}"));
      },
    );
  });
  tearDown(() => bloc.close());
}
