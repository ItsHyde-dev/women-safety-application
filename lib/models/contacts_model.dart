import 'package:hive/hive.dart';
part 'contacts_model.g.dart';

@HiveType(typeId: 0)
class Contact extends HiveObject {
  @HiveField(1)
  late String name;
  @HiveField(2)
  late String email;
  @HiveField(3)
  late String number;
}
