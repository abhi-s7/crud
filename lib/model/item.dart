class Item {
  String id;
  String title;
  String desc;
  String imageUrl;

  Item({this.id, this.title, this.desc, this.imageUrl = ''});

  Map<String, dynamic> toJson() =>
      {'title': this.title, 'desc': this.desc, 'imageUrl': this.imageUrl};

  static Item fromJson(Map<String, dynamic> json) => Item(
      id: json['id'],
      title: json['title'],
      desc: json['desc'],
      imageUrl: json['imageUrl']);

  @override
  String toString() {
    // TODO: implement toString
    print('ITEM= id: $id title: $title desc: $desc imageUrl: $imageUrl');
    return super.toString();
  }
}
