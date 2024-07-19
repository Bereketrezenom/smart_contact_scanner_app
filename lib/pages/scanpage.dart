import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:virtualcard_holder/models/contactmodel.dart';
import 'package:virtualcard_holder/pages/form_page.dart';
import 'package:virtualcard_holder/utils/constants.dart';

class ScanPage extends StatefulWidget {
  static const String routeName = 'scan';

  const ScanPage({super.key, required String title});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool isScanOver = false;
  List<String> lines = [];
  String name = '',
      mobile = '',
      email = '',
      address = '',
      company = '',
      designation = '',
      website = '',
      image = '';

  void createContact() {
    final contact = ContactModel(
      name: name,
      mobile: mobile,
      email: email,
      address: address,
      company: company,
      designation: designation,
      website: website,
      image: image,
    );
    context.goNamed(
      FormPage.routeName,
      extra: contact,
    );
  }

  Future<void> manualEntry() async {
    final result = await showDialog<ContactModel>(
      context: context,
      builder: (context) => ManualEntryDialog(),
    );

    if (result != null) {
      context.goNamed(
        FormPage.routeName,
        extra: result,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Page'),
        actions: [
          IconButton(
            onPressed: image.isEmpty ? null : createContact,
            icon: Icon(Icons.arrow_forward),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  getImage(ImageSource.camera);
                },
                icon: const Icon(Icons.camera),
                label: const Text('Capture'),
              ),
              TextButton.icon(
                onPressed: () {
                  getImage(ImageSource.gallery);
                },
                icon: const Icon(Icons.photo_album),
                label: const Text('Gallery'),
              ),
              TextButton.icon(
                onPressed: manualEntry,
                icon: const Icon(Icons.edit),
                label: const Text('Manual Entry'),
              ),
            ],
          ),
          if (isScanOver)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    DragTargetItem(
                        property: ContactProperties.name,
                        onDrop: getPropertyValue),
                    DragTargetItem(
                        property: ContactProperties.mobile,
                        onDrop: getPropertyValue),
                    DragTargetItem(
                        property: ContactProperties.email,
                        onDrop: getPropertyValue),
                    DragTargetItem(
                        property: ContactProperties.company,
                        onDrop: getPropertyValue),
                    DragTargetItem(
                        property: ContactProperties.designation,
                        onDrop: getPropertyValue),
                    DragTargetItem(
                        property: ContactProperties.address,
                        onDrop: getPropertyValue),
                    DragTargetItem(
                        property: ContactProperties.website,
                        onDrop: getPropertyValue),
                  ],
                ),
              ),
            ),
          if (isScanOver)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(hint),
            ),
          Wrap(
            children: lines.map((line) => LineItem(line: line)).toList(),
          ),
        ],
      ),
    );
  }

  void getImage(ImageSource source) async {
    final xFile = await ImagePicker().pickImage(source: source);
    if (xFile != null) {
      setState(() {
        image = xFile.path;
      });
      EasyLoading.show(status: 'Loading...');
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer
          .processImage(InputImage.fromFile(File(xFile.path)));
      EasyLoading.dismiss();
      final tempList = <String>[];
      for (var block in recognizedText.blocks) {
        for (var line in block.lines) {
          tempList.add(line.text);
        }
      }
      setState(() {
        lines = tempList;
        isScanOver = true;
      });
    }
  }

  void getPropertyValue(String property, String value) {
    switch (property) {
      case ContactProperties.name:
        name = value;
        break;
      case ContactProperties.mobile:
        mobile = value;
        break;
      case ContactProperties.email:
        email = value;
        break;
      case ContactProperties.company:
        company = value;
        break;
      case ContactProperties.designation:
        designation = value;
        break;
      case ContactProperties.address:
        address = value;
        break;
      case ContactProperties.website:
        website = value;
        break;
    }
  }
}

class LineItem extends StatelessWidget {
  final String line;

  const LineItem({
    super.key,
    required this.line,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable(
      data: line,
      dragAnchorStrategy: childDragAnchorStrategy,
      feedback: Container(
        key: GlobalKey(),
        padding: const EdgeInsets.all(8.0),
        decoration: const BoxDecoration(
          color: Colors.black45,
        ),
        child: Text(
          line,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.white),
        ),
      ),
      child: Chip(
        label: Text(line),
      ),
    );
  }
}

class DragTargetItem extends StatefulWidget {
  final String property;
  final Function(String, String) onDrop;

  const DragTargetItem({
    super.key,
    required this.property,
    required this.onDrop,
  });

  @override
  State<DragTargetItem> createState() => _DragTargetItemState();
}

class _DragTargetItemState extends State<DragTargetItem> {
  String dragItem = '';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(widget.property),
        ),
        Expanded(
          flex: 2,
          child: DragTarget<String>(
            builder: (context, candidateData, rejectedData) => Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: candidateData.isNotEmpty
                    ? Border.all(color: Colors.red, width: 2)
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(dragItem.isEmpty ? 'Drop here' : dragItem),
                  ),
                  if (dragItem.isNotEmpty)
                    InkWell(
                      onTap: () {
                        setState(() {
                          dragItem = '';
                        });
                      },
                      child: const Icon(
                        Icons.clear,
                        size: 15,
                      ),
                    )
                ],
              ),
            ),
            onAccept: (value) {
              setState(() {
                if (dragItem.isEmpty) {
                  dragItem = value;
                } else {
                  dragItem += ' $value';
                }
              });
              widget.onDrop(widget.property, dragItem);
            },
          ),
        ),
      ],
    );
  }
}

class ManualEntryDialog extends StatefulWidget {
  @override
  _ManualEntryDialogState createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<ManualEntryDialog> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _companyController = TextEditingController();
  final _designationController = TextEditingController();
  final _websiteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Contact Details'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _buildTextField('Name', _nameController),
            _buildTextField('Mobile', _mobileController),
            _buildTextField('Email', _emailController),
            _buildTextField('Address', _addressController),
            _buildTextField('Company', _companyController),
            _buildTextField('Designation', _designationController),
            _buildTextField('Website', _websiteController),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final contact = ContactModel(
              name: _nameController.text,
              mobile: _mobileController.text,
              email: _emailController.text,
              address: _addressController.text,
              company: _companyController.text,
              designation: _designationController.text,
              website: _websiteController.text,
              image: '', // You can add image path if available
            );
            Navigator.of(context).pop(contact);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
