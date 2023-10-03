import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactManager {
  ContactManager._privateConstructor();

  static final ContactManager instance = ContactManager._privateConstructor();

  ///Ask Permission for Contacts
  Future<void> askPermissions() async {
    PermissionStatus permissionStatus = await getContactPermission();
    if (permissionStatus != PermissionStatus.granted) {
      handleInvalidPermissions(permissionStatus);
    }
  }

  ///FETCH STORED PERMISSION
  Future<PermissionStatus> getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;

    if (permission != PermissionStatus.granted /*&& permission != PermissionStatus.restricted*/) {
      Map<Permission, PermissionStatus> permissionStatus = await [
        Permission.contacts,
        Permission.manageExternalStorage,
        Permission.storage
      ].request();

      PermissionStatus permission = permissionStatus[Permission.contacts] ?? PermissionStatus.denied;
      print('Contact permission status - $permission');
      return permission;
    } else {
      print('Contact permission status - $permission');
      return permission;
    }
  }

  ///HANDLE INVALID PERMISSION
  void handleInvalidPermissions(PermissionStatus permissionStatus) {
    // print('VERY BAD BRO -DENIED');
    if (permissionStatus == PermissionStatus.denied) {
      throw PlatformException(code: 'PERMISSION_DENIED', message: 'Access to Contacts Denied', details: null);
    } else if (permissionStatus == PermissionStatus.restricted) {
      throw PlatformException(code: 'PERMISSION_DISABLED', message: 'Contacts data is not available on device', details: null);
    }
  }

  ///Get Local Contacts
  Future<List<Contact>> getLocalContacts(BuildContext context) async {
    // if (getIsIOSPlatform()) {
    //   List<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);
    //   return contacts;
    // } else {
      PermissionStatus permissionStatus = await getContactPermission();
      List<Contact> contacts = [];
      if (permissionStatus == PermissionStatus.granted) {
        contacts = await ContactsService.getContacts(withThumbnails: false);
      }
      return contacts;
    // }
  }

  Future<PermissionStatus> getSMSPermissionStatus() async {
    PermissionStatus permission = await Permission.sms.status;
    return permission;
  }

  ///FETCH SMS PERMISSION
  Future<PermissionStatus> getSMSPermission() async {
    PermissionStatus permission = await Permission.sms.status;

    if (permission != PermissionStatus.granted /*&& permission != PermissionStatus.restricted*/) {
      Map<Permission, PermissionStatus> permissionStatus = await [
        Permission.sms,
      ].request();

      PermissionStatus permission = permissionStatus[Permission.sms] ?? PermissionStatus.denied;
      print('SMS permission status - $permission');
      return permission;
    } else {
      print('SMS permission status - $permission');
      return permission;
    }
  }
}
class ContactData{
 String?
     displayName,
     middleName,
 contactNumber;

 ContactData({this.displayName,this.contactNumber,this.middleName});
}