import 'package:hive/hive.dart';

part 'hive_contact.g.dart';

@HiveType(typeId: 0)
class Contact extends HiveObject {
  Contact({
    required this.name,
    required this.contactNo,
    required this.date,
  });

  @HiveField(0)
  late String name;
  @HiveField(1)
  final int contactNo;
  @HiveField(2)
  final DateTime date;

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        name: json["name"],
        contactNo: json["contact"],
        date: DateTime.parse(json["date"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "contact": contactNo,
        "date": date.toIso8601String(),
      };

  @override
  bool operator ==(Object other) {
    return other is Contact && other.contactNo == contactNo;
  }

  @override
  int get hashCode => contactNo.hashCode;
}
