import 'package:hive/hive.dart';
part 'mail_model.g.dart';

@HiveType(typeId: 1)
class Mail extends HiveObject {
  @HiveField(1)
  late String mail;
  @HiveField(2)
  late bool location;
}
