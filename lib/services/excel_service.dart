import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ExcelService {
  // load file excel
  Future<File?> loadExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      return file;
    } else {
      return null;
    }
  }

  // read excel file
  Future<Excel> readExcelFile(File file) async {
    final excel = Excel.decodeBytes(file.readAsBytesSync());
    return excel;
  }

  // write excel file
  Future<void> writeExcelFile(Excel excel) async {
    final excel = Excel.createExcel();
    excel.save();
  }
}
