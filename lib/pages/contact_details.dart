import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:virtualcard_holder/models/contactmodel.dart';
import 'package:virtualcard_holder/providers/contactprovider.dart';
import 'package:virtualcard_holder/utils/helperfunction.dart';

class ContactDetailsPage extends StatefulWidget {
  static const String routeName = 'details';
  final int id;

  const ContactDetailsPage({super.key, required this.id});

  @override
  State<ContactDetailsPage> createState() => _ContactDetailsPageState();
}

class _ContactDetailsPageState extends State<ContactDetailsPage> {
  late int id;
  bool isEditingMobile = false;
  bool isEditingEmail = false;
  bool isEditingAddress = false;
  bool isEditingWebsite = false;

  late TextEditingController mobileController;
  late TextEditingController emailController;
  late TextEditingController addressController;
  late TextEditingController websiteController;

  @override
  void initState() {
    id = widget.id;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: Consumer<ContactProvider>(
        builder: (context, provider, child) => FutureBuilder<ContactModel>(
          future: provider.getContactById(id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final contact = snapshot.data!;
              mobileController = TextEditingController(text: contact.mobile);
              emailController = TextEditingController(text: contact.email);
              addressController = TextEditingController(text: contact.address);
              websiteController = TextEditingController(text: contact.website);

              return ListView(
                padding: const EdgeInsets.all(8.0),
                children: [
                  buildEditableField(
                    context: context,
                    title: 'Mobile',
                    value: contact.mobile,
                    isEditing: isEditingMobile,
                    controller: mobileController,
                    onSave: () async {
                      try {
                        setState(() {
                          isEditingMobile = false;
                          contact.mobile = mobileController.text;
                        });
                        await provider.updateContact(contact);
                        showMsg(context, 'Mobile number updated');
                      } catch (e) {
                        showMsg(context, 'Failed to update mobile number: $e');
                      }
                    },
                    onEdit: () {
                      setState(() {
                        isEditingMobile = true;
                      });
                    },
                    icon: Icons.call,
                    onIconPressed: () {
                      callContact(contact.mobile);
                    },
                    additionalIcon: Icons.sms,
                    onAdditionalIconPressed: () {
                      sendSms(contact.mobile);
                    },
                  ),
                  buildEditableField(
                    context: context,
                    title: 'Email',
                    value: contact.email,
                    isEditing: isEditingEmail,
                    controller: emailController,
                    onSave: () async {
                      try {
                        setState(() {
                          isEditingEmail = false;
                          contact.email = emailController.text;
                        });
                        await provider.updateContact(contact);
                        showMsg(context, 'Email updated');
                      } catch (e) {
                        showMsg(context, 'Failed to update email: $e');
                      }
                    },
                    onEdit: () {
                      setState(() {
                        isEditingEmail = true;
                      });
                    },
                    icon: Icons.email,
                    onIconPressed: () {
                      _openBrowser(contact.email);
                    },
                  ),
                  buildEditableField(
                    context: context,
                    title: 'Address',
                    value: contact.address,
                    isEditing: isEditingAddress,
                    controller: addressController,
                    onSave: () async {
                      try {
                        setState(() {
                          isEditingAddress = false;
                          contact.address = addressController.text;
                        });
                        await provider.updateContact(contact);
                        showMsg(context, 'Address updated');
                      } catch (e) {
                        showMsg(context, 'Failed to update address: $e');
                      }
                    },
                    onEdit: () {
                      setState(() {
                        isEditingAddress = true;
                      });
                    },
                    icon: Icons.map,
                    onIconPressed: () {
                      _openMap(contact.address);
                    },
                  ),
                  buildEditableField(
                    context: context,
                    title: 'Website',
                    value: contact.website,
                    isEditing: isEditingWebsite,
                    controller: websiteController,
                    onSave: () async {
                      try {
                        setState(() {
                          isEditingWebsite = false;
                          contact.website = websiteController.text;
                        });
                        await provider.updateContact(contact);
                        showMsg(context, 'Website updated');
                      } catch (e) {
                        showMsg(context, 'Failed to update website: $e');
                      }
                    },
                    onEdit: () {
                      setState(() {
                        isEditingWebsite = true;
                      });
                    },
                    icon: Icons.web,
                    onIconPressed: () {
                      _openBrowser(contact.website);
                    },
                  ),
                ],
              );
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text('Failed to load data'),
              );
            }
            return const Center(
              child: Text('Please wait...'),
            );
          },
        ),
      ),
    );
  }

  Widget buildEditableField({
    required BuildContext context,
    required String title,
    required String value,
    required bool isEditing,
    required TextEditingController controller,
    required Function onSave,
    required Function onEdit,
    required IconData icon,
    required Function onIconPressed,
    IconData? additionalIcon,
    Function? onAdditionalIconPressed,
  }) {
    return ListTile(
      title: isEditing
          ? TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: title,
              ),
            )
          : Text(value.isEmpty ? 'Not found' : value),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon),
            onPressed: () {
              onIconPressed();
            },
          ),
          if (additionalIcon != null && onAdditionalIconPressed != null)
            IconButton(
              icon: Icon(additionalIcon),
              onPressed: () {
                onAdditionalIconPressed();
              },
            ),
          isEditing
              ? IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () {
                    onSave();
                  },
                )
              : IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    onEdit();
                  },
                ),
        ],
      ),
    );
  }

  void callContact(String mobile) async {
    final url = 'tel:$mobile';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      showMsg(context, 'Cannot perform this task');
    }
  }

  void sendSms(String mobile) async {
    final url = 'sms:$mobile';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      showMsg(context, 'Cannot perform this task');
    }
  }

  void _openBrowser(String url) async {
    final formattedUrl = url.startsWith('http') ? url : 'https://$url';
    if (await canLaunchUrlString(formattedUrl)) {
      await launchUrlString(formattedUrl);
    } else {
      showMsg(context, 'Could not perform this operation');
    }
  }

  void _openMap(String address) async {
    String query = Uri.encodeComponent(address);
    final url = 'https://www.google.com/maps/search/?api=1&query=$query';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      showMsg(context, 'Could not perform this operation');
    }
  }
}
