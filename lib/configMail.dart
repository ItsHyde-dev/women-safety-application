import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safety_application/db/email_database.dart';
import 'package:safety_application/models/email_model.dart';

import 'functions.dart';

class ConfigMail extends StatelessWidget {
  const ConfigMail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ConfigMailStateFull(
      storage: Functions(),
    ));
  }
}

class ConfigMailStateFull extends StatefulWidget {
  final Functions storage;

  const ConfigMailStateFull({Key? key, required this.storage})
      : super(key: key);

  @override
  _ConfigMailStateFullState createState() => _ConfigMailStateFullState();
}

class _ConfigMailStateFullState extends State<ConfigMailStateFull> {
  TextEditingController customEmailController = TextEditingController();
  bool isLoading = false;
  late List<Mail> mail;
  bool isChecked = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshMail().whenComplete(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/blue.jpg'), fit: BoxFit.cover)),
          child: editor()),
    ));
  }

  Widget editor() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: TextFormField(
                controller: customEmailController,
                decoration: InputDecoration(
                  hintText: "Customize your emergency message",
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                    checkColor: Colors.blue,
                    value: isChecked,
                    onChanged: (bool? value){
                      setState((){
                        isChecked = value!;
                        print(value);
                      });
                    }
                ),
                Text(
                  "Send location?",
                  style: TextStyle(
                      color: Colors.white
                  ),
                )
              ],
            ),
            OutlinedButton(
              onPressed: () {
                Mail newMail = Mail(
                    id: mail[0].id,
                    mail: customEmailController.text.toString(),
                    location: isChecked.toString(),
                );

                updateMail(newMail);
              },
              child: Text("Save Changes"),
              style: OutlinedButton.styleFrom(
                  primary: Colors.white, backgroundColor: Colors.black),
            ),


          ]),
    );
  }

  Future refreshMail() async {
    setState(() {
      isLoading = true;
    });

    this.mail = await EmailDatabase.instance.readAllMails();
    if (!mail.isNotEmpty) {
      print('new one being created');
      await EmailDatabase.instance.create(Mail(mail: ' ', location: isChecked.toString()));
    }
    customEmailController.text = mail[0].mail.toString();
    isChecked = (mail[0].location == 'true');
    setState(() {
      isLoading = false;
    });
  }

  Future updateMail(Mail newMail) async {
    await EmailDatabase.instance.update(newMail);
  }
}
