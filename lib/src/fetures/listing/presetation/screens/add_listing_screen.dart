import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> selectedImages = [];

  Future<void> _pickImages() async {
    final List<XFile> pickedFile = await _picker.pickMultiImage();
    final finalImages = pickedFile
        .map(
          (xFile) => File(xFile.path),
        )
        .toList();
    if (pickedFile.isNotEmpty) {
      setState(() {
        selectedImages.addAll(finalImages);
      });
    }
  }

  Future<void> _showEditOptions(int index) async {
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Remove image'),
                onTap: () {
                  setState(() {
                    selectedImages.removeAt(index);
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(CupertinoIcons.xmark)),
        title: Text('Ad Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: selectedImages.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.photo_library, size: 48.0),
                          ElevatedButton(
                            onPressed: _pickImages,
                            child: Text('Add Images'),
                          ),
                          SizedBox(
                            height: 8.0,
                            width: double.infinity,
                          ),
                          Text('Select All the images of the bike'),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black, width: 1.0),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: _pickImages,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: selectedImages.map((image) {
                                      int index = selectedImages.indexOf(image);
                                      return Padding(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 5),
                                        child: GestureDetector(
                                          onTap: () => _showEditOptions(index),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: SizedBox(
                                              height: 100,
                                              width: 100,
                                              child: Image.file(
                                                image,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Tap on images to edit them.'),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      persistentFooterButtons: [
        SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: () {}, child: Text('Submit')))
      ],
    );
  }
}
