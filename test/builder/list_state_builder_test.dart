import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:simple_list_bloc/simple_list_bloc.dart';
import 'package:simple_list_bloc/src/bloc/list/list_bloc.dart';
import 'package:simple_list_bloc/src/bloc/list/list_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockListBloc extends MockBloc<ListEvent, ListState<int, bool>> implements ListBloc<int, bool> {}

class MockListEvent extends ListEvent {
  @override
  List<Object?> get props => throw UnimplementedError();
}

void main() {
  MockListBloc? bloc;

  setUp(() => bloc = MockListBloc());

  setUpAll(() {
    registerFallbackValue<ListState<int, bool>>(ListState<int, bool>(filter: false));
    registerFallbackValue<ListEvent>(MockListEvent());
  });

  Widget buildView() {
    return MaterialApp(
      home: Scaffold(
        body: ListStateBuilder<MockListBloc>(
          bloc: bloc,
          onInit: (context) => Text("init", key: Key("init")),
          onSuccess: (context) => Text("success", key: Key("success")),
          onEmpty: (context) => Text("empty", key: Key("empty")),
          onError: (context, event, message, fullscreen) =>
              !fullscreen ? Text("$message", key: Key("fc_error")) : Text("$message", key: Key("error")),
          onLoading: (context, fullscreen) => !fullscreen ? Text("loading", key: Key("fc_loading")) : Text("loading", key: Key("loading")),
        ),
      ),
    );
  }

  Widget buildSuccessOnlyView() {
    return MaterialApp(
      home: Scaffold(
        body: ListStateBuilder<MockListBloc>(
          bloc: bloc,
          onSuccess: (context) => Text("success", key: Key("success")),
        ),
      ),
    );
  }

  testWidgets('should diplay init widget when bloc is in inital state', (WidgetTester tester) async {
    when(() => bloc!.state).thenReturn(ListState(filter: false));

    await tester.pumpWidget(buildView());

    expect(find.byKey(Key("init")), findsOneWidget);

    expect(find.byKey(Key("success")), findsNothing);
    expect(find.byKey(Key("loading")), findsNothing);
    expect(find.byKey(Key("fc_loading")), findsNothing);
    expect(find.byKey(Key("error")), findsNothing);
    expect(find.byKey(Key("fc_error")), findsNothing);
    expect(find.byKey(Key("empty")), findsNothing);
  });

  testWidgets('should diplay loading widget when bloc is loading', (WidgetTester tester) async {
    when(() => bloc!.state).thenReturn(ListState(initialized: true, loading: true, filter: false));

    await tester.pumpWidget(buildView());

    expect(find.byKey(Key("loading")), findsOneWidget);

    expect(find.byKey(Key("init")), findsNothing);
    expect(find.byKey(Key("success")), findsNothing);
    expect(find.byKey(Key("fc_loading")), findsNothing);
    expect(find.byKey(Key("error")), findsNothing);
    expect(find.byKey(Key("fc_error")), findsNothing);
    expect(find.byKey(Key("empty")), findsNothing);
  });

  testWidgets('should diplay loading widget and success widget when bloc is loading with items', (WidgetTester tester) async {
    when(() => bloc!.state).thenReturn(ListState(items: [1, 2, 3], initialized: true, loading: true, filter: false));

    await tester.pumpWidget(buildView());

    expect(find.byKey(Key("fc_loading")), findsOneWidget);
    expect(find.byKey(Key("success")), findsOneWidget);

    expect(find.byKey(Key("init")), findsNothing);
    expect(find.byKey(Key("loading")), findsNothing);
    expect(find.byKey(Key("error")), findsNothing);
    expect(find.byKey(Key("fc_error")), findsNothing);
    expect(find.byKey(Key("empty")), findsNothing);
  });

  testWidgets('should diplay empty widget when bloc is loaded with empty array', (WidgetTester tester) async {
    when(() => bloc!.state).thenReturn(ListState(initialized: true, loading: false, filter: false));

    await tester.pumpWidget(buildView());

    expect(find.byKey(Key("empty")), findsOneWidget);

    expect(find.byKey(Key("init")), findsNothing);
    expect(find.byKey(Key("success")), findsNothing);
    expect(find.byKey(Key("loading")), findsNothing);
    expect(find.byKey(Key("fc_loading")), findsNothing);
    expect(find.byKey(Key("error")), findsNothing);
    expect(find.byKey(Key("fc_error")), findsNothing);
  });

  testWidgets('should diplay error widget when bloc has error message', (WidgetTester tester) async {
    when(() => bloc!.state).thenReturn(ListState(initialized: true, loading: false, error: "err", filter: false));

    await tester.pumpWidget(buildView());

    expect(find.byKey(Key("error")), findsOneWidget);
    expect(find.text("err"), findsOneWidget);

    expect(find.byKey(Key("init")), findsNothing);
    expect(find.byKey(Key("success")), findsNothing);
    expect(find.byKey(Key("loading")), findsNothing);
    expect(find.byKey(Key("fc_loading")), findsNothing);
    expect(find.byKey(Key("fc_error")), findsNothing);
    expect(find.byKey(Key("empty")), findsNothing);
  });

  testWidgets('should diplay error widget and success widget when bloc has error message and items', (WidgetTester tester) async {
    when(() => bloc!.state).thenReturn(ListState(items: [1, 2, 3], initialized: true, loading: false, error: "err", filter: false));

    await tester.pumpWidget(buildView());

    expect(find.byKey(Key("fc_error")), findsOneWidget);
    expect(find.byKey(Key("success")), findsOneWidget);
    expect(find.text("err"), findsOneWidget);

    expect(find.byKey(Key("init")), findsNothing);
    expect(find.byKey(Key("loading")), findsNothing);
    expect(find.byKey(Key("fc_loading")), findsNothing);
    expect(find.byKey(Key("error")), findsNothing);
    expect(find.byKey(Key("empty")), findsNothing);
  });

  testWidgets('should diplay success widget when builder does not have onError builder', (WidgetTester tester) async {
    when(() => bloc!.state).thenReturn(ListState(items: [1, 2, 3], initialized: true, loading: false, error: "err", filter: false));

    await tester.pumpWidget(buildSuccessOnlyView());

    expect(find.byKey(Key("success")), findsOneWidget);
    expect(find.byKey(Key("error")), findsNothing);

    expect(find.byKey(Key("init")), findsNothing);
    expect(find.byKey(Key("loading")), findsNothing);
    expect(find.byKey(Key("fc_loading")), findsNothing);
    expect(find.byKey(Key("fc_error")), findsNothing);
    expect(find.byKey(Key("empty")), findsNothing);
  });

  tearDown(() => bloc!.close());
}
