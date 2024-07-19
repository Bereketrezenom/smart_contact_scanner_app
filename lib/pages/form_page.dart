import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:virtualcard_holder/models/contactmodel.dart';
import 'package:virtualcard_holder/pages/home_page.dart';
import 'package:virtualcard_holder/providers/contactprovider.dart';
import 'package:virtualcard_holder/utils/constants.dart';
import 'package:virtualcard_holder/utils/helperfunction.dart';

class FormPage extends StatefulWidget {
  static const String routeName = 'form';
  final ContactModel contactModel;
  const FormPage({super.key, required this.contactModel, required String title});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final companyController = TextEditingController();
  final designationController = TextEditingController();
  final webController = TextEditingController();

  @override
  void initState() {
    nameController.text = widget.contactModel.name;
    mobileController.text = widget.contactModel.mobile;
    emailController.text = widget.contactModel.email;
    addressController.text = widget.contactModel.address;
    companyController.text = widget.contactModel.company;
    designationController.text = widget.contactModel.designation;
    webController.text = widget.contactModel.website;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Page'),
        actions: [
          IconButton(
            onPressed: saveContact,
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Contact Name'
              ),
              validator: (value) {
                if(value == null || value.isEmpty) {
                  return emptyErrormsg;
                }
                return null;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.phone,
              controller: mobileController,
              decoration: InputDecoration(
                  labelText: 'Mobile Number'
              ),
              validator: (value) {
                if(value == null || value.isEmpty) {
                  return emptyErrormsg;
                }
                return null;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
              decoration: InputDecoration(
                  labelText: 'Email'
              ),
              validator: (value) {
                return null;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.phone,
              controller: addressController,
              decoration: InputDecoration(
                  labelText: 'Street Address'
              ),
              validator: (value) {
                return null;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.phone,
              controller: companyController,
              decoration: InputDecoration(
                  labelText: 'Company Name'
              ),
              validator: (value) {
                return null;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.phone,
              controller: designationController,
              decoration: InputDecoration(
                  labelText: 'Designation'
              ),
              validator: (value) {
                return null;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.phone,
              controller: webController,
              decoration: InputDecoration(
                  labelText: 'Website'
              ),
              validator: (value) {
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    companyController.dispose();
    designationController.dispose();
    webController.dispose();
    super.dispose();
  }

  void saveContact() async {
    if(_formKey.currentState!.validate()) {
      widget.contactModel.name = nameController.text;
      widget.contactModel.mobile = mobileController.text;
      widget.contactModel.email = emailController.text;
      widget.contactModel.address = addressController.text;
      widget.contactModel.company = companyController.text;
      widget.contactModel.designation = designationController.text;
      widget.contactModel.website = webController.text;
      //print(widget.contactModel);

      Provider.of<ContactProvider>(context, listen: false)
          .insertContact(widget.contactModel)
          .then((value) {
        if (value > 0) {
          showMsg(context, 'Saved');
          context.goNamed(HomePage.routeName);
        }
      })
          .catchError((error) {
        showMsg(context, 'Failed to save');
      });
    }
  }
}
