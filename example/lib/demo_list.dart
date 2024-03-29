import 'package:example/demo_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:simple_list_bloc/simple_list_bloc.dart';

/// Sample list view to show selection, filter and pagination
class DemoListView extends StatefulWidget {
  DemoListView({Key? key}) : super(key: key);

  @override
  _DemoListViewState createState() => _DemoListViewState();
}

class _DemoListViewState extends State<DemoListView> {
  // the list bloc
  final DemoListBloc listBloc = DemoListBloc();

  // selection bloc to keep track of selection mode and list of selected item
  final ListSelectionBloc<DemoModel> selectionBloc = ListSelectionBloc();

  // global key to keep listview scroll position when change state
  final GlobalKey key = GlobalKey();

  @override
  void initState() {
    listBloc.add(FetchItems<String>(filter: ""));
    selectionBloc.selectItems([DemoModel("en", "English")]);
    super.initState();
  }

  @override
  void dispose() {
    listBloc.close();
    selectionBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Demo Selectable, Filtered & Paginated list"),
        actions: [
          StreamBuilder(
            stream: selectionBloc.stream,
            initialData: selectionBloc.state,
            builder: (BuildContext context, AsyncSnapshot snapshot) => buildAppBarMenu(context),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.clear),
        onPressed: () => listBloc.add(RemoveItems(selectionBloc.items)),
      ),
      body: Column(
        children: [
          TextField(
            onChanged: (value) {
              listBloc.add(FetchItems<String>(filter: value, clear: true));
            },
          ),
          Expanded(
            child: ListStateBuilder<DemoListBloc>(
              bloc: listBloc,
              onInit: (context) => Center(child: Text("Initializing")),
              onLoading: buildLoading,
              onEmpty: buildEmpty,
              onError: buildErrorView,
              onSuccess: buildList,
            ),
          )
        ],
      ),
    );
  }

  /// build app bar's menu
  Widget buildAppBarMenu(BuildContext context) {
    if (selectionBloc.state.selecting) {
      return Row(
        children: [
          IconButton(
            icon: Icon(Icons.select_all),
            onPressed: () => selectionBloc.selectItems(listBloc.state.items),
            tooltip: "Select All",
          ),
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: () => selectionBloc.clearSelection(endSelectionMode: false),
            tooltip: "Clear All",
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => selectionBloc.toggleSelection(),
            tooltip: "Close",
          ),
        ],
        mainAxisSize: MainAxisSize.min,
      );
    } else {
      return IconButton(icon: Icon(Icons.edit), onPressed: () => selectionBloc.toggleSelection());
    }
  }

  /// loading indicator
  Widget buildLoading(BuildContext context, bool fullscreen) {
    // if fullscreen show message at center
    if (fullscreen) return Center(child: Text("Loading"));

    // else message will show at bottom of listview
    return Container(
      child: ListTile(title: Text("Loading More Items"), trailing: CircularProgressIndicator()),
      color: Colors.lightBlueAccent,
    );
  }

  /// view to display when list is empty
  Widget buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text("No Data"), TextButton(child: Text("Reload"), onPressed: () => listBloc.add(RefreshList()))],
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
        trailing: event == null ? null : TextButton(child: Text("Retry"), onPressed: () => listBloc.add(event)),
      ),
      color: Colors.redAccent,
    );
  }

  /// the list view
  ListView buildList(BuildContext context) {
    var max = listBloc.state.hasReachedMax;
    var count = listBloc.state.items.length + (max ? 0 : 1);
    return ListView.builder(
      key: key,
      padding: EdgeInsets.all(0),
      itemBuilder: buildItem,
      itemCount: count,
    );
  }

  /// build item row
  Widget buildItem(BuildContext context, int index) {
    if (index >= listBloc.state.items.length) {
      listBloc.fetchNextPage();
      return SizedBox();
    }
    var item = listBloc.state.items[index];
    return ListTile(
      title: Text("${item.language}"),
      onTap: () => selectionBloc.toggleItem(item),
      trailing: buildSelectedIndicator(context, item),
    );
  }

  /// build a check mark if selected
  Widget buildSelectedIndicator(BuildContext context, DemoModel item) {
    return SelectionStreamBuilder(
      target: item,
      selectionBloc: selectionBloc,
      builder: (context, state, data, hasTarget) {
        if (hasTarget) {
          return Icon(Icons.check_circle);
        }
        return SizedBox();
      },
    );
  }
}
