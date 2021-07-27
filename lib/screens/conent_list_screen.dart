import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:techdaily/models/TechDailyContent.dart';
import 'package:techdaily/models/api_owner_model.dart';
import 'package:techdaily/services/api_manager.dart';
import 'package:techdaily/widgets/chips_filter_widget.dart';
import 'package:techdaily/widgets/content_list_widget.dart';
import 'package:techdaily/widgets/drawer_widget.dart';

class ContentListScreen extends StatefulWidget {
  @override
  _ContentListScreenState createState() => _ContentListScreenState();
}

class _ContentListScreenState extends State<ContentListScreen> {
  bool _isSorted = false;
  bool _isLoading = true;
  List<String> chipsLabels = [];
  int currentOwner;
  Object redrawObject;

  bool shouldSort = false;
  List<TechDailyContent> allContents = [];
  List<TechDailyContent> sortedContents = [];

  List<TechDailyOwner> owners = [];
  Map<int, String> ownersMap = {};

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    print('Widget building');
    return Scaffold(
      // key: _scaffoldKey,
      drawer: DrawerWidget(),
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.black,
              floating: true,
              leading: Builder(builder: (context) {
                return IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                );
              }),
              title: Container(
                margin: EdgeInsets.only(right: 35),
                child: Transform.scale(
                  scale: .60,
                  child: GestureDetector(
                      onTap: () => _scrollToTop(),
                      child: Image.asset('assets/images/techlogo.png')),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 60,
                      padding: EdgeInsets.only(left: 6, top: 30),
                      child: ListView.builder(
                        key: ValueKey<Object>(redrawObject),
                        shrinkWrap: true,
                        itemCount: owners.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return ChipFilter(
                            ownerId: owners[index].id,
                            ownerName: owners[index].name,
                            shouldSelect:
                                currentOwner == owners[index].id ? true : false,
                            onSelect: () {
                              setState(() {
                                currentOwner = owners[index].id;
                                redrawObject = Object();
                              });

                              handleOnSelect(owners[index].id);
                            },
                            onUnselect: () {
                              print('onUnSelect' + index.toString());

                              setState(() {
                                redrawObject = Object();
                                currentOwner = -1;
                              });
                              handleOnUnselect();
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : !_isSorted
                            ? ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.only(top: 10),
                                shrinkWrap: true,
                                itemCount: allContents.length,
                                itemBuilder: (context, index) {
                                  return ContentList(
                                    title: allContents[index].title,
                                    img: allContents[index].imgUrl,
                                    uploadTime: allContents[index].pubDate,
                                    owner:
                                        ownersMap[allContents[index].owner] ??
                                            allContents[index].owner.toString(),
                                    url: allContents[index].url,
                                  );
                                },
                              )
                            : _isSorted
                                ? ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.only(top: 10),
                                    shrinkWrap: true,
                                    itemCount: sortedContents.length,
                                    itemBuilder: (context, index) {
                                      return ContentList(
                                        title: sortedContents[index].title,
                                        img: sortedContents[index].imgUrl,
                                        uploadTime:
                                            sortedContents[index].pubDate,
                                        owner: ownersMap[
                                                sortedContents[index].owner] ??
                                            sortedContents[index]
                                                .owner
                                                .toString(),
                                        url: sortedContents[index].url,
                                      );
                                    },
                                  )
                                : Center(
                                    child: Text(
                                      'No Data',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void handleOnSelect(int ownerId) {
    print('chip selected ' + ownerId.toString());
    ApiManager()
        .getContentsByOwner(ownerId)
        .then((List<TechDailyContent> value) {
      setState(() {
        sortedContents = value;
      });
    });

    setState(() {
      sortedContents.addAll(allContents.where((TechDailyContent content) {
        return content.owner == currentOwner;
      }));
      _isSorted = true;
    });
  }

  void handleOnUnselect() {
    setState(() {
      _isSorted = false;
    });
  }

  void _scrollToTop() {
    print('Trying to scroll.....');
    _scrollController.animateTo(0.0,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    // _scrollController.jumpTo(_scrollController.position.minScrollExtent);
  }

  @override
  void initState() {
    ApiManager().getContents().then((List<TechDailyContent> value) {
      setState(() {
        allContents = value;
      });
    });

    ApiManager().getOwners().then((List<TechDailyOwner> value) {
      Map<int, String> map = {};
      for (TechDailyOwner owner in value) {
        map[owner.id] = owner.name;
      }
      setState(() {
        ownersMap = map;
        owners = value;

        _isLoading = false;
      });
    });

    super.initState();
  }
}
