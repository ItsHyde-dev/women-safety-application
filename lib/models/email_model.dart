import 'package:geolocator/geolocator.dart';
import 'package:safety_application/models/contacts_model.dart';

final String tableEmail = 'email';

class emailFields {
  static final List<String> values = [id, mail];

  static final String id = '_id';
  static final String mail = 'mail';
  static final String location = 'location';
}

class Mail {
  final String mail;
  final int? id;
  final String? location;

  const Mail({required this.mail,
  this.id, required this.location});

  static Mail fromJson(Map<String, Object?> json) => Mail(
    id: json[emailFields.id] as int?,
    mail: json[emailFields.mail] as String,
    location: json[emailFields.location] as String
  );

  Map<String, Object?> toJson() =>{
    emailFields.mail: mail,
    emailFields.id: id,
    emailFields.location: location
  };

  Mail copy({
    int? id,
    String? mail,
    String? location

  }) => Mail(
    id: id?? this.id,
    mail: mail?? this.mail,
    location: location?? this.location
  );
}
