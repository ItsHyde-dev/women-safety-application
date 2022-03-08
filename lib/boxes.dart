import 'package:hive/hive.dart';
import 'models/contacts_model.dart';
import 'models/mail_model.dart';

class Boxes {
  static Box<Contact> getContacts() => Hive.box<Contact>('contacts');
  static Box<Mail> getEmail() => Hive.box<Mail>('email');
}
