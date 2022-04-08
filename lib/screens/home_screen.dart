import 'package:crud/db/db.dart';
import 'package:crud/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/item.dart';
import 'add_edit_item_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  DbOperation dbOperation = new DbOperation();

  @override
  void initState() {
    super.initState();
    if (auth.currentUser == null) {
      auth.signOut();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDissmissed = false;
    Query query = dbOperation.fetchItems(uid: auth.currentUser.uid);
    Widget buildSwipeActionLeft() => Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10)),
              color: Colors.red),
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Icon(
            Icons.delete,
            color: Colors.white,
            size: 32,
          ),
        );

    Widget buildItems(Item item) => Container(
          margin: EdgeInsets.all(20),
          child: Dismissible(
            key: UniqueKey(),
            dismissThresholds: {DismissDirection.startToEnd: 0.5},
            direction: DismissDirection.startToEnd,
            background: buildSwipeActionLeft(),
            onDismissed: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                //isDissmissed = !isDissmissed;
                print('Update data: $item');
                print('Swipe to right');
                await dbOperation.deleteItem(
                    item: item, uid: auth.currentUser.uid);
              } else {}
            },
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        borderRadius: !isDissmissed
                            ? BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10))
                            : BorderRadius.zero,
                        color: !isDissmissed ? Colors.grey : Colors.red),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10)),
                      child: item.imageUrl != null && item.imageUrl.isNotEmpty
                          ? FadeInImage.assetNetwork(
                              placeholder:
                                  'assets/images/image_placeholder.JPG',
                              image: '${item.imageUrl}',
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/image_placeholder.JPG',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text('${item.title}'),
                      subtitle: Text('${item.desc}'),
                      trailing: GestureDetector(
                        child: CircleAvatar(
                          child: Icon(
                            Icons.edit_outlined,
                            color: Color(0xff694fa0),
                            size: 18,
                          ),
                          backgroundColor: Color(0xffebddfe),
                        ),
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) => AddEditItemScreen(
                                    item: item,
                                    isEdit: true,
                                  ));
                          print(item);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

    void handleClick(int item) {
      switch (item) {
        case 0:
          auth.signOut();
//          Navigator.push(
//              context, MaterialPageRoute(builder: (context) => LoginScreen()));
          Navigator.of(context).pushNamedAndRemoveUntil(
              LoginScreen.id, (Route<dynamic> route) => false);
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ITEM', style: TextStyle(color: Colors.black)),
        backgroundColor: Color(0xfff3edf7),
        actions: <Widget>[
          PopupMenuButton<int>(
            onSelected: (item) => handleClick(item),
            itemBuilder: (context) => [
              PopupMenuItem<int>(value: 0, child: Text('Logout')),
            ],
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Icon(Icons.add, color: Colors.black),
          backgroundColor: Color(0xffffd8e3),
          elevation: 20,
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (context) => AddEditItemScreen(
                      item: null,
                      isEdit: false,
//                      app: widget.app,
                    ));
          },
        ),
      ),
      body: StreamBuilder(
        stream: query.snapshots(),
        //dbOperation.loadItems(),
        builder: (context, stream) {
          if (stream.connectionState == ConnectionState.waiting) {
            // i.e. it is waiting for the data and data hasn't been received
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (stream.hasError) {
            return Text('Something went Wrong! ${stream.error}');
          } else if (stream.hasData) {
            QuerySnapshot querySnapshot = stream.data;
            return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot documentSnapshot = querySnapshot.docs[index];
                Map<String, dynamic> dataMap = documentSnapshot
                    .data(); // it gives a key:value pair - > it is always a map -> inside of a document
                Item item = Item(
                    id: documentSnapshot.id,
                    title: dataMap['title'],
                    desc: dataMap['desc'],
                    imageUrl: dataMap['imageUrl']);

                return buildItems(item);
              },
              itemCount: querySnapshot.size,
            );
          } else {
            return Text('Something went Wrong!');
          }
        },
      ),
    );
  }
}
