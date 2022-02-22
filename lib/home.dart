// ignore_for_file: avoid_print

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String downloadlink = 'Getting Download Link....';
  // Getting File From Storage...
  File? file;
  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    final path = result.files.single.path!;
    setState(() {
      file = File(path);
    });
  }

  // Uploading File To Firebase Storage
  Future<void> uploadFile() async {
    final filename = basename(file!.path);
    try {
      await FirebaseStorage.instance.ref('files/$filename').putFile(file!);
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  // Downloading Url
  Future<void> downloadURL() async {
    final filename = basename(file!.path);
    String downloadURL =
        await FirebaseStorage.instance.ref('files/$filename').getDownloadURL();

    print('Download URL:- $downloadURL');
    setState(() {
      downloadlink = downloadURL;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filename = file != null ? basename(file!.path) : 'No File Selected';
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePage'),
      ),
      body: Center(
        child: Column(
          children: [
            const Spacer(),
            file == null
                ? const Text(
                    'No Download Link Available !!',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  )
                : Container(
                    height: MediaQuery.of(context).size.width / 2,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: SelectableText(
                      downloadlink,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              width: MediaQuery.of(context).size.width / 1.2,
              child: ElevatedButton(
                onPressed: selectFile,
                child: const Text('Select File'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width / 1.2,
              child: Text(
                filename,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 60,
              width: MediaQuery.of(context).size.width / 1.2,
              child: ElevatedButton(
                onPressed: () async {
                  await uploadFile();
                  // Showing message to user
                  final snackBar = SnackBar(
                    content: const Text('File Uploaded To Firebase!'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {},
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  downloadURL();
                },
                child: const Text('Upload File'),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
