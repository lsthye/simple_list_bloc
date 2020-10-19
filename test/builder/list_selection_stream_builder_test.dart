import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:simple_list_bloc/simple_list_bloc.dart';
import 'package:simple_list_bloc/src/bloc/list/list_bloc.dart';
import 'package:simple_list_bloc/src/bloc/list/list_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockListBloc extends MockBloc implements ListBloc<int, bool> {}

void main() {
  MockListBloc bloc;
  ListSelectionBloc<int> selectionBloc;

  setUp(() {
    bloc = MockListBloc();
    selectionBloc = ListSelectionBloc();
  });

  Widget buildView() {
    return MaterialApp(
      home: Scaffold(
        body: ListStateBuilder<MockListBloc>(
          bloc: bloc,
          onSuccess: (context) => ListView.builder(
            itemBuilder: (context, index) {
              var item = bloc.state.items[index];
              return SelectionStreamBuilder(
                builder: (context, state, target, selected) {
                  return ListTile(
                    title: Text("$index", key: Key("item_$index")),
                    trailing: selected ? Text("$selected", key: Key("selected_$index")) : null,
                  );
                },
                target: item,
                selectionBloc: selectionBloc,
              );
            },
            itemCount: bloc.state.items.length,
          ),
        ),
      ),
    );
  }

  testWidgets('should not render any select when start', (WidgetTester tester) async {
    when(bloc.state).thenReturn(ListState(items: [0, 1, 2, 3]));

    await tester.pumpWidget(buildView());

    expect(find.byKey(Key("item_0")), findsOneWidget);
    expect(find.byKey(Key("selected_0")), findsNothing);

    expect(find.byKey(Key("item_1")), findsOneWidget);
    expect(find.byKey(Key("selected_1")), findsNothing);

    expect(find.byKey(Key("item_2")), findsOneWidget);
    expect(find.byKey(Key("selected_2")), findsNothing);

    expect(find.byKey(Key("item_3")), findsOneWidget);
    expect(find.byKey(Key("selected_3")), findsNothing);
  });

  testWidgets('should not render any select when selected item was not in list', (WidgetTester tester) async {
    when(bloc.state).thenReturn(ListState(items: [0, 1, 2, 3]));

    await tester.pumpWidget(buildView());

    selectionBloc.selectItems([5]);
    await tester.runAsync(() => Future.delayed(Duration(milliseconds: 200)));
    await tester.pump(Duration(milliseconds: 100));

    expect(selectionBloc.items.length, equals(1));
    expect(selectionBloc.items[0], equals(5));

    expect(find.byKey(Key("item_0")), findsOneWidget);
    expect(find.byKey(Key("selected_0")), findsNothing);

    expect(find.byKey(Key("item_1")), findsOneWidget);
    expect(find.byKey(Key("selected_1")), findsNothing);

    expect(find.byKey(Key("item_2")), findsOneWidget);
    expect(find.byKey(Key("selected_2")), findsNothing);

    expect(find.byKey(Key("item_3")), findsOneWidget);
    expect(find.byKey(Key("selected_3")), findsNothing);
  });

  testWidgets('should render selected on item added into selection', (WidgetTester tester) async {
    when(bloc.state).thenReturn(ListState(items: [0, 1, 2, 3]));

    await tester.pumpWidget(buildView());

    selectionBloc.selectItems([2, 3]);
    await tester.runAsync(() => Future.delayed(Duration(milliseconds: 200)));
    await tester.pump(Duration(milliseconds: 100));

    expect(selectionBloc.items.length, equals(2));
    expect(selectionBloc.items[0], equals(2));
    expect(selectionBloc.items[1], equals(3));

    expect(find.byKey(Key("item_0")), findsOneWidget);
    expect(find.byKey(Key("selected_0")), findsNothing);

    expect(find.byKey(Key("item_1")), findsOneWidget);
    expect(find.byKey(Key("selected_1")), findsNothing);

    expect(find.byKey(Key("item_2")), findsOneWidget);
    expect(find.byKey(Key("selected_2")), findsOneWidget);

    expect(find.byKey(Key("item_3")), findsOneWidget);
    expect(find.byKey(Key("selected_3")), findsOneWidget);

    selectionBloc.toggleItem(2);
    await tester.runAsync(() => Future.delayed(Duration(milliseconds: 100)));
    await tester.pump(Duration(milliseconds: 100));

    expect(find.byKey(Key("item_0")), findsOneWidget);
    expect(find.byKey(Key("selected_0")), findsNothing);

    expect(find.byKey(Key("item_1")), findsOneWidget);
    expect(find.byKey(Key("selected_1")), findsNothing);

    expect(find.byKey(Key("item_2")), findsOneWidget);
    expect(find.byKey(Key("selected_2")), findsNothing);

    expect(find.byKey(Key("item_3")), findsOneWidget);
    expect(find.byKey(Key("selected_3")), findsOneWidget);
  });

  tearDown(() {
    bloc.close();
    selectionBloc.close();
  });
}
