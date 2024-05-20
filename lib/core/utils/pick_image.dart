import 'package:file_picker/file_picker.dart';

Future<FilePickerResult?> pickImage() async {
  final image = await FilePicker.platform.pickFiles(type: FileType.image);

  return image;
}

Future<FilePickerResult?> pickImages() async {
  final image = await FilePicker.platform
      .pickFiles(allowMultiple: true, type: FileType.image);

  return image;
}
