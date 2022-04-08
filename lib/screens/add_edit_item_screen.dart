import 'package:crud/db/db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/item.dart';
import '../utils/utility_functions.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class AddEditItemScreen extends StatefulWidget {
  final Item item;
  final bool isEdit;

//  final FirebaseApp app;
  AddEditItemScreen({Key key, @required this.item, @required this.isEdit})
      : super(key: key);

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseStorage fbs;
  bool showProgressBar = false;
  String imagePath;
  String imageURL = '';
  String status;
  File imageFile;
  List<String> storageList;
  DbOperation dbOperation = new DbOperation();
  TextEditingController titleTextController;
  TextEditingController descTextController;

  _callOpenGallery() async {
    imageFile = await UtilityFunctions.openCameraOrGallery();
    setState(() {});
  }

  _callSetStates(value) {
    setState(() {
      showProgressBar = value;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // loadFS();

    if (widget.isEdit) {
      titleTextController = TextEditingController(text: widget.item.title);
      descTextController = TextEditingController(text: widget.item.desc);
      imageURL = widget.item.imageUrl;
    } else {
      titleTextController = TextEditingController();
      descTextController = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    fbs = FirebaseStorage.instanceFor(
//        app: widget.app, bucket: "gs://crud-virtuostack.appspot.com");
        app: Provider.of<FirebaseApp>(context),
        bucket: "gs://crud-virtuostack.appspot.com");
    return ModalProgressHUD(
      inAsyncCall: showProgressBar,
      child: Container(
        color: Color(0xff757575),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEdit ? 'Edit Item' : 'Add Item',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: _callOpenGallery,
                  child: Container(
                      width: 110,
                      height: 130,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.grey),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: imageFile == null
                            ? (imageURL.isNotEmpty
                                ? FadeInImage.assetNetwork(
                                    placeholder:
                                        'assets/images/image_placeholder.JPG',
                                    image: '$imageURL',
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/images/image_placeholder.JPG',
                                    fit: BoxFit.cover,
                                  ))
                            : Image.file(imageFile),
                      )),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: titleTextController,
                  decoration: InputDecoration(
                    hintText: 'Title',
                    labelText: 'Title',
                    labelStyle: TextStyle(color: Color(0xff694fa0)),
                    floatingLabelStyle: TextStyle(color: Color(0xff694fa0)),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: descTextController,
                  decoration: InputDecoration(
                    hintText: 'Description',
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Color(0xff694fa0)),
                    floatingLabelStyle: TextStyle(color: Color(0xff694fa0)),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Material(
                  color: Color(0xff694fa0),
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  elevation: 5.0,
                  child: MaterialButton(
                    onPressed: () async {
                      _callSetStates(true);
                      //Implement login functionality
                      print('Title: ${titleTextController.text}');
                      print('Desc: ${descTextController.text}');
                      if (titleTextController.text.isEmpty ||
                          descTextController.text.isEmpty) {
                        print('Please enter all the details');
                        _callSetStates(false);
                        return;
                      }

                      if (widget.isEdit) {
                        widget.item.title = titleTextController.text;
                        widget.item.desc = descTextController.text;

                        if (imageFile == null) {
                          dbOperation.updateItem(
                              item: widget.item, uid: auth.currentUser.uid);
                          _callSetStates(false);
                          Navigator.pop(context);
                        } else {
                          UtilityFunctions.getDownloadUrl(
                                  fbs: fbs, imageFile: imageFile)
                              .then((storageUrl) {
                            print('Inside then: $storageUrl');
                            if (null != storageUrl &&
                                !storageUrl.startsWith('Error:')) {
                              widget.item.imageUrl = storageUrl;
                              dbOperation.updateItem(
                                  item: widget.item, uid: auth.currentUser.uid);
                              print('Updated');
                            } else {
                              print('Something went wrong');
                            }
                            _callSetStates(false);
                            Navigator.pop(context);
                          }).catchError((e) {
                            print('Error: $e');
                            _callSetStates(false);
                            Navigator.pop(context);
                          });
                        }
                      } else {
                        // when the user add the item for the first time
                        final item = Item(
                          title: titleTextController.text,
                          desc: descTextController.text,
                        );

                        if (imageFile == null) {
                          dbOperation.addItem(
                              item: item, uid: auth.currentUser.uid);
                          _callSetStates(false);
                          Navigator.pop(context);
                        } else {
                          UtilityFunctions.getDownloadUrl(
                                  fbs: fbs, imageFile: imageFile)
                              .then((storageUrl) {
                            print('Inside then: $storageUrl');
                            if (storageUrl != null &&
                                !storageUrl.startsWith('Error:')) {
                              item.imageUrl = storageUrl;
                              dbOperation.addItem(
                                  item: item, uid: auth.currentUser.uid);
                              print('Saved');
                            } else {
                              print('Something went wrong');
                            }
                            _callSetStates(false);
                            Navigator.pop(context);
                          }).catchError((e) {
                            print('Error: $e');
                            _callSetStates(false);
                            Navigator.pop(context);
                          });
                        }
                      }
                    },
                    minWidth: media.width,
                    height: 32.0,
                    child: Text(
                      'SAVE',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
