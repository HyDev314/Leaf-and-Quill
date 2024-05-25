import 'package:file_picker/file_picker.dart';

Future<FilePickerResult?> pickImage() async {
  final image = await FilePicker.platform.pickFiles(type: FileType.image);

  return image;
}

Future<FilePickerResult?> pickVideo() async {
  final video = await FilePicker.platform.pickFiles(type: FileType.video);

  return video;
}
