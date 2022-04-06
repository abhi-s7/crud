import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud/model/item.dart';

class DbOperation {
  Future addItem({Item item}) async {
    final docUser = FirebaseFirestore.instance.collection('items').doc();
    final json = item.toJson();
    print('Json is $json');
    await docUser.set(json);
  }

  Query fetchItems() {
    Query query = FirebaseFirestore.instance.collection('items');
    return query;
  }

  Future updateItem({Item item}) async {
    final docUser = FirebaseFirestore.instance.collection('items').doc(item.id);
    await docUser.update(
        {'title': item.title, 'desc': item.desc, 'imageUrl': item.imageUrl});
  }

  Future deleteItem({Item item}) async {
    final docUser = FirebaseFirestore.instance.collection('items').doc(item.id);
    await docUser.delete();
  }

  Stream<List<Item>> loadItems() => FirebaseFirestore.instance
      .collection('items')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Item.fromJson(doc.data())).toList());
}
