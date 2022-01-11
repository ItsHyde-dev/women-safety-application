import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
class Functions{
    Future<String> get _localPath async{
        final directory = await getApplicationDocumentsDirectory();
        return directory.path;
    }

    Future<File> get _localFile async{
        final path = await _localPath;
        return File('$path/contacts.txt');
    }

    Future<List<String>> readData() async{
            final file = await _localFile;
            List<String> body = await file.readAsLines();
            return body;
    }

    Future<void> writeFile(List<String> data) async{
        final file = await _localFile;
        var sink = file.openWrite();
        data.forEach((element) {
          print(element);
          sink.write('${element} \n');
        });

        sink.close();
    }
}
