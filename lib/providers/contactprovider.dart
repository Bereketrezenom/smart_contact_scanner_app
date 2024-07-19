import 'package:flutter/foundation.dart';
import 'package:virtualcard_holder/db/db_vcard.dart';
import 'package:virtualcard_holder/models/contactmodel.dart';

class ContactProvider extends ChangeNotifier {
  List<ContactModel> contactList = [];
  final db = db_vcard();

  Future<int> insertContact(ContactModel contactModel) async {
    final rowId = await db.insertContact(contactModel);
    contactModel.id = rowId;
    contactList.add(contactModel);
    notifyListeners();
    return rowId;
  }

  Future<void> getAllContacts() async {
    contactList = await db.getAllContacts();
    notifyListeners();
  }

  Future<ContactModel> getContactById(int id) => db.getContactById(id);

  Future<void> getAllFavoriteContacts() async {
    contactList = await db.getAllFavoriteContacts();
    notifyListeners();
  }

  Future<int> deleteContact(int id) async {
    final result = await db.deleteContact(id);
    if (result > 0) {
      contactList.removeWhere((contact) => contact.id == id);
      notifyListeners();
    }
    return result;
  }

  Future<void> updateFavorite(ContactModel contactModel) async {
    final value = contactModel.favorite ? 0 : 1;
    await db.updateFavorite(contactModel.id, value);
    final index = contactList.indexWhere((c) => c.id == contactModel.id);
    if (index != -1) {
      contactList[index].favorite = !contactList[index].favorite;
      notifyListeners();
    }
  }

  Future<void> updateContact(ContactModel contactModel) async {
    try {
      await db.updateContact(contactModel);
      final index = contactList.indexWhere((c) => c.id == contactModel.id);
      if (index != -1) {
        contactList[index] = contactModel; // Update the contact in the list
        notifyListeners();
      }
    } catch (e) {
      print('Error updating contact: $e');
      throw e; // Rethrow the error to handle it in the UI
    }
  }
}
