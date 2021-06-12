import 'package:image_picker/image_picker.dart';

class MediaService {
  static MediaService instance = MediaService();

  Future<PickedFile?> getImageFromLibrary() async {
    var pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    // final File file = File(pickedFile!.path);
    return pickedFile;
  }
}
