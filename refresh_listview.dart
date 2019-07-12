import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class RefreshListView extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final Widget noDataWidget;

  final Future<void> Function() onHeaderRefresh;
  final Future<void> Function() onFooterRefresh;

  RefreshListView({
    Key key,
    this.noDataWidget,
    this.onHeaderRefresh,
    this.onFooterRefresh,
    @required this.itemCount,
    @required this.itemBuilder,
  })  : assert(itemBuilder != null),
        super(key: key);

  _RefreshListViewState createState() => _RefreshListViewState();
}

class _RefreshListViewState extends State<RefreshListView> {
  ScrollController _scrollController = ScrollController();

  bool _footerIsLoading = false;

  bool _footerCanRefresh = false;

  ///to save scroll bottom border
  double _scrollBottom;

  footerRefresh() async {
    if (_footerIsLoading) return;
    if (widget.onFooterRefresh==null) return;
    setState(() {
      _footerIsLoading = true;
    });
    await widget.onFooterRefresh().then((v) {
      setState(() {
        _footerIsLoading = false;
      });
    });
  }

  @override
  initState() {
    super.initState();
    _footerIsLoading = false;
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent != _scrollBottom) {
        _scrollBottom = _scrollController.position.maxScrollExtent;
        _footerCanRefresh = true;
      }
      ///当拖到超过底边时，
      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent &&
          _footerCanRefresh) {
        _footerCanRefresh = false;
        footerRefresh();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onHeaderRefresh,
      child: (widget.itemCount == 0)
          ? SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              child: widget.noDataWidget ??
                  Container(
                    child: Center(
                      child: Text(
                        'no data',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
            )
          : ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              itemCount: widget.itemCount + 1,
              itemBuilder: (context, index) {
                if (index == widget.itemCount) {
                  return !_footerIsLoading
                      ? Container()
                      : Center(
                          child: CupertinoActivityIndicator(),
                        );
                }
                return widget.itemBuilder(context, index);
              },
            ),
    );
  }
}
