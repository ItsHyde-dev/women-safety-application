final String tableContacts = 'contacts';

class contactsFields{

  static final List<String> values = [
    id, name, email, number
  ];

  static final String id = '_id';
  static final String name = 'name';
  static final String email = 'email';
  static final String number = 'number';
}

class Contact {
  final int? id;
  final String name;
  final String email;
  final String number;


  const Contact ({
    this.id,
    required this.name,
    required this.email,
    required this.number
  });

  static Contact fromJson(Map<String, Object?> json) => Contact(
    id: json[contactsFields.id] as int?,
    name: json[contactsFields.name] as String,
    email: json[contactsFields.email] as String,
    number: json[contactsFields.number] as String,
  );

  Map<String, Object?> toJson() =>{
    contactsFields.id: id,
    contactsFields.name: name,
    contactsFields.email: email,
    contactsFields.number: number
  };

  Contact copy({
    int? id,
    String? name,
    String? email,
    String? number
  }) => Contact(
    id: id?? this.id,
    name: name?? this.name,
    email: email?? this.email,
    number: number?? this.number,
  );
}
