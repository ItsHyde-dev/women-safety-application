import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safety_application/db/contacts_database.dart';
import 'package:safety_application/db/email_database.dart';
import 'package:safety_application/models/contacts_model.dart';
import 'package:shake/shake.dart';
import 'contacts.dart';
import 'models/email_model.dart';
import 'videos.dart';
import 'configMail.dart';
import 'package:safety_application/api/google_auth_api.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'functions.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final String title = 'Safety App';

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: MainPage(
        title: title,
        storage: Functions(),
    ),
    title: title,
    theme: ThemeData(
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          primary: Colors.white,
          backgroundColor: Colors.black,
          side: BorderSide(
            color: Colors.tealAccent,
            width: 1,
          ),
        ),
      ),
    )
  );
}

class MainPage extends StatefulWidget {
  final String title;
  final Functions storage;

  const MainPage({
      required this.title,
      required this.storage
  });

  @override
  _MainPageState createState() => _MainPageState();
}

//also the UI of the application
class _MainPageState extends State<MainPage> {

  late ShakeDetector detector;
  int counter = 0;
  late final user;

  @override
  void initState() {
    super.initState();
    GoogleAuthApi.signOut();
    getUser();
    getLocationAccess();
    detector = ShakeDetector.autoStart(
      onPhoneShake: () {
        print("this phone  was shaked $counter");
        Timer(Duration(seconds: 4), (){
          counter>0?counter=0:null;
        });
        if(counter > 3){
          print("this is an emergency");
          sendIt();
          counter = 0;
        }
        counter++;
      },
    );

    compute(keepDetectionAlive, detector);

  }

  @override
  void dispose() {
    detector.stopListening();
    GoogleAuthApi.signOut();
    super.dispose();
  }

  void sendIt(){
    sendEmail(user);
  }

  @override
  Widget build(BuildContext context){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent
    ));
    return MaterialApp(
        theme: ThemeData(
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
                primary: Colors.black87,
                backgroundColor: Colors.lightBlueAccent,

                padding: EdgeInsets.all(10),
                // side: BorderSide(
                //   color: Colors.tealAccent,
                // ),
                fixedSize: Size(500, 55)
            ),
          ),
        ),
        home: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          appBar: null,
          // AppBar(
          //   backgroundColor: Colors.white10,
          //   title: Center(
          //     child: Text(
          //       widget.title,
          //       style: TextStyle(
          //         color: Colors.white,
          //       ),
          //     ),
          //   ),
          // )
          body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/blue.jpg"),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45)
                  ),
                  color: Colors.black54
                ),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //Video button
                          OutlinedButton(onPressed: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Videos())
                            );
                          },
                            child: Text("To videos"),
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                            )
                          ),
                          OutlinedButton(onPressed: (){
                            sendEmail(user);
                          },
                            child: Text("Send email"),
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                              )
                          ),
                          OutlinedButton(
                            onPressed: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Contacts())
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Configure Emergency Contacts",
                                ),
                                Icon(
                                  Icons.mail_outline,
                                  color: Colors.black87,

                                ),
                              ],
                            ),
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                              )
                            // style : OutlinedButton.styleFrom(
                            //   primary: Colors.white,
                            //   backgroundColor: Colors.black,
                            //   side: BorderSide(
                            //     color: Colors.tealAccent,
                            //     width: 0.8,
                            //   ),
                            // ),
                          ),
                          OutlinedButton(onPressed: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ConfigMail()
                            ));
                          },
                            child: Text("Customise Email"),
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                              )
                          ),
                        ],
                      )
                  ),
                ),
              ),

          ),

    );
  }

  Future getUser() async{
    user = await GoogleAuthApi.signIn();
  }

  Future getLocationAccess() async{
    bool serviceEnabled;
    LocationPermission permission;

    print('permissions was reached');

    // serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // print(serviceEnabled);
    // if (!serviceEnabled) {
    //
    //   return Future.error('Location services are disabled.');
    // }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {

        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {

      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

}

void keepDetectionAlive(ShakeDetector detector) async{

}



Future sendEmail(user) async{

  // print('this was reached');

  List <String> emails = [];

  // await storage.readData().then((List<String> value) {
  //   readFile = value;
  //   readFile.remove(' ');
  //   for(String line in readFile){
  //     List<String> splitLine = line.split('///');
  //     emails.add(splitLine[1]);
  //   }
  // });

  List<Contact> contactList = await ContactsDatabase.instance.readAllContacts();

  if(contactList.isNotEmpty){
    for(Contact contactInstance in contactList){
      emails.add(contactInstance.email);
    }
  }


  // final user = await GoogleAuthApi.signIn();

  if (user == null) return;

  final email = user.email;
  final auth = await user.authentication;
  final token = auth.accessToken!;

  final smtpServer = gmailSaslXoauth2(email, token);

  Position location = await Geolocator.getCurrentPosition();

  List<Mail> mailContentList = await EmailDatabase.instance.readAllMails();
  String mailContent = mailContentList[0].mail.toString();
  if(mailContentList[0].location! == 'true'){
    mailContent = mailContent + "\nthis is my current location\nhttps://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}";
  }
  else{
    print('The location was not enabled');
  }


  List<Address> adds = [];

  for (String emailInstance in emails){
    print(emailInstance);
    adds.add(Address(emailInstance.trim()));
  }

  final message = Message()
    ..from = Address(email, 'Safety Application')
    ..recipients.addAll(adds)
    ..subject = 'Mail from Safety Application'
    ..text = mailContent;

    try{
      await send(message, smtpServer);

      print("the message was sent");
    }
    on MailerException catch (e){
      print(e);
    }
}
