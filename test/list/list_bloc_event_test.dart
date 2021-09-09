import 'package:simple_list_bloc/src/bloc/list/list_event.dart';
import 'package:simple_list_bloc/src/bloc/list/list_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('publish state event', () {
    test('should be equal when both event have same state', () {
      var state = ListState(filter: false);
      var first = PublishState(state);
      var second = PublishState(state);
      expect(first, equals(second));
    });
    test('should not be equal when both event have different state', () {
      var first = PublishState(ListState(filter: false));
      var second = PublishState(ListState(filter: false));
      expect(first, isNot(equals(second)));
    });
    test('toString should contain runtime type and state value', () {
      var state = ListState<int, bool>(filter: false);
      var event = PublishState<int, bool>(state);
      expect(event.toString(),
          'PublishState<int, bool> state = ListState<int, bool> { uuid: ${state.uuid}, items: 0, hasReachedMax: false, filter: false, extra: null, loading: false, initialized: false, error:  }');
    });
  });

  group('refresh event', () {
    test('refresh event should always not equals', () {
      var first = RefreshList();
      var second = RefreshList();
      expect(first, isNot(equals(second)));
    });
    test('toString should contain runtime type', () {
      var event = RefreshList();
      expect(event.toString(), 'RefreshList');
    });
  });

  group('fetch event', () {
    test('should not be equal even when both event have same filter, retry won\'t work if it was equals', () {
      var first = FetchItems<int>(filter: 1);
      var second = FetchItems<int>(filter: 1);
      expect(first, isNot(equals(second)));
    });
    test('should not be equal when both event have different filter', () {
      var first = FetchItems<int>(filter: 1);
      var second = FetchItems<int>(filter: 2);
      expect(first, isNot(equals(second)));
    });
    test('toString should contain runtime type and state value', () {
      var event = FetchItems<int>(filter: 2);
      expect(event.toString(), 'FetchItems<int> { filter: 2 }');
    });
  });

  group('add items event', () {
    test('should be equal when both event have same item', () {
      var first = AddItems<int>([1, 2, 3]);
      var second = AddItems<int>([1, 2, 3]);
      expect(first, equals(second));
    });
    test('should not be equal when both event have different filter', () {
      var first = AddItems<int>([1, 2, 3]);
      var second = AddItems<int>([1, 2, 4]);
      expect(first, isNot(equals(second)));
    });
    test('toString should contain runtime type and state value', () {
      var event = AddItems<int>([1, 2, 3]);
      expect(event.toString(), 'AddItems<int> { items: [1, 2, 3] }');
    });
  });

  group('remove items event', () {
    test('should be equal when both event have same item', () {
      var first = RemoveItems<int>([1, 2, 3]);
      var second = RemoveItems<int>([1, 2, 3]);
      expect(first, equals(second));
    });
    test('should not be equal when both event have different filter', () {
      var first = RemoveItems<int>([1, 2, 3]);
      var second = RemoveItems<int>([1, 2, 4]);
      expect(first, isNot(equals(second)));
    });
    test('toString should contain runtime type and state value', () {
      var event = RemoveItems<int>([1, 2, 3]);
      expect(event.toString(), equals('RemoveItems<int> { items: [1, 2, 3] }'));
    });
  });
}
