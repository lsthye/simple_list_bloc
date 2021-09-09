import 'package:equatable/equatable.dart';
import 'package:example/demo_grid.dart';
import 'package:example/demo_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_list_bloc/simple_list_bloc.dart';

/// Data model
class SimpleListDataModel extends Equatable {
  final String key;
  final String text;
  SimpleListDataModel(this.key, this.text);

  @override
  List<Object> get props => [key];
}

/// List bloc
class SimpleListBloc extends ListBloc<SimpleListDataModel, dynamic> {
  SimpleListBloc() : super(viewCount: -1, debounce: 50, debug: true, state: ListState(filter: ""));

  @override
  Future<List<SimpleListDataModel>> fetchItems(filter, int skip, int count) async {
    /// delay to show loading indicator
    await Future.delayed(Duration(seconds: 1));
    return [
      SimpleListDataModel("listview", "List View"),
      SimpleListDataModel("gridview", "Grid View"),
      SimpleListDataModel("staggered", "Staggered Grid View"),
    ];
  }
}

/// The page
class SimpleList extends StatefulWidget {
  SimpleList({Key? key}) : super(key: key);

  @override
  _SimpleListState createState() => _SimpleListState();
}

class _SimpleListState extends State<SimpleList> {
  /// The bloc
  final SimpleListBloc bloc = SimpleListBloc();

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  void initState() {
    bloc.add(FetchItems());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Simple list"),
      ),
      // Pull to refresh
      body: RefreshIndicator(
        onRefresh: () async {
          if (!bloc.state.loading) {
            bloc.add(RefreshList());
            await Future.delayed(Duration(milliseconds: 100));
            while (bloc.state.loading) {
              await Future.delayed(Duration(milliseconds: 50));
            }
          }
        },
        child: ListStateBuilder<SimpleListBloc>(
          bloc: bloc,
          onInit: (context) => Center(child: Text("Initializing")),
          onLoading: buildLoading,
          onEmpty: buildEmpty,
          onError: buildErrorView,
          onSuccess: buildListView,
        ),
      ),
    );
  }

  /// loading indicator
  Widget buildLoading(BuildContext context, bool fullscreen) {
    // if fullscreen show message at center
    if (fullscreen) return Center(child: Text("Loading"));

    // else message will show at bottom of listview
    return Container(child: ListTile(title: Text("Loading More Items")), color: Colors.lightBlueAccent);
  }

  /// view to display when list is empty
  Widget buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text("No Data"), TextButton(child: Text("Reload"), onPressed: () => bloc.add(RefreshList()))],
      ),
    );
  }

  /// view to display error thrown in bloc
  Widget buildErrorView(BuildContext context, ListEvent? event, String message, bool fullscreen) {
    // if fullscreen show message at center
    if (fullscreen) return Center(child: Text("Error: $message"));

    // else message will show at bottom of listview
    return Container(
      child: ListTile(
        title: Text("Error: $message"),
        trailing: event == null ? null : TextButton(child: Text("Retry"), onPressed: () => bloc.add(event)),
      ),
      color: Colors.redAccent,
    );
  }

  /// build the list view
  ListView buildListView(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemBuilder: buildItem,
      itemCount: bloc.state.items.length,
    );
  }

  /// build item row
  Widget buildItem(BuildContext context, int index) {
    var item = bloc.state.items[index];
    return ListTile(title: Text("${item.text}"), onTap: () => onItemTap(context, item));
  }

  /// navigate to diffent page to show more complex sample
  onItemTap(BuildContext context, SimpleListDataModel item) {
    Widget? page;
    if (item.key == "listview") {
      page = DemoListView();
    } else if (item.key == "gridview") {
      page = DemoGridView();
    } else if (item.key == "staggered") {
      // TODO:
    }
    if (page != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => page!));
    }
  }
}
