import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UtilityFunctions {
  File imageFile;
  static Future<File> openCameraOrGallery() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile =
        await imagePicker.getImage(source: ImageSource.gallery);
    File imageFile = File(pickedFile.path);
    print("Image Path is $imageFile");

    return imageFile;
  }

  static Future<String> getDownloadUrl(
      {FirebaseStorage fbs, File imageFile}) async {
    String imagePath = "images/${DateTime.now()}.jpg";
    Reference ref = fbs.ref().child(imagePath);
    UploadTask uploadTask = ref.putFile(imageFile);
    String downloadURL;
    await uploadTask.then((TaskSnapshot tasksnapshot) async {
      downloadURL = await tasksnapshot.ref.getDownloadURL();
      print('Download url is $downloadURL');
    }).catchError((err) {
      downloadURL = 'Error: ' + err;
    });

    print('After then error');
    return downloadURL;
  }
}
