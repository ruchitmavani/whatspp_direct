import 'package:hive/hive.dart';
import 'package:whatspp_direct/constants.dart';
import 'package:whatspp_direct/models/hive_contact.dart';

class Boxes{
  static Box<Contact>getContacts()=>Hive.box<Contact>(StringConstants.contacts);
}