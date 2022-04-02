import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:safety_application/models/contacts_model.dart';
import 'package:shake/shake.dart';
import 'contacts.dart';

import 'videos.dart';
import 'configMail.dart';
import 'package:safety_application/api/google_auth_api.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/contacts_model.dart';
import 'models/mail_model.dart';
import 'boxes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(ContactAdapter());
  Hive.registerAdapter(MailAdapter());
  await Hive.openBox<Contact>('contacts');
  await Hive.openBox<Mail>('email');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String title = 'Safety App';

  @override
  Widget build(BuildContext context) => MaterialApp(
      home: MainPage(
        title: title,
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
      ));
}

class MainPage extends StatefulWidget {
  final String title;

  const MainPage({required this.title});

  @override
  _MainPageState createState() => _MainPageState();
}

//also the UI of the application
class _MainPageState extends State<MainPage> {
  late ShakeDetector detector;
  int counter = 0;
  late final user;
  bool userLoadedBool = false;

  @override
  void initState() {
    super.initState();
    GoogleAuthApi.signOut();
    getUser().whenComplete(() => userLoaded());
    getLocationAccess();
    detector = ShakeDetector.autoStart(
      onPhoneShake: () {
        print("this phone  was shaked $counter");
        Timer(Duration(seconds: 4), () {
          counter > 0 ? counter = 0 : null;
        });
        if (counter > 3) {
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

  void sendIt() {
    sendEmail(user);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
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
              fixedSize: Size(500, 55)),
        ),
      ),
      home: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.black,
            title: Text(
              "Safety Application",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xffc4c4c4),
                fontSize: 24,
                fontFamily: "Inter",
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Container(
          //         width: 428,
          //         height: 63,
          //         color: Colors.black,
          //         padding: const EdgeInsets.only(
          //           left: 107,
          //           right: 24,
          //           top: 20,
          //           bottom: 19,
          //         ),
          //         child: Text(
          //           "Safety Application",
          //           textAlign: TextAlign.center,
          //           style: TextStyle(
          //             color: Color(0xffc4c4c4),
          //             fontSize: 24,
          //             fontFamily: "Inter",
          //             fontWeight: FontWeight.w600,
          //           ),
          //         ),
          //       ),

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
          body: (userLoadedBool) ? HomePageNew(context, user) : null),
    );
  }

  Future getUser() async {
    user = await GoogleAuthApi.signIn();
  }

  Future getLocationAccess() async {
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

  userLoaded() {
    setState(() {
      userLoadedBool = true;
    });
  }
}

void keepDetectionAlive(ShakeDetector detector) async {}

Future sendEmail(user) async {
  // print('this was reached');

  // await storage.readData().then((List<String> value) {
  //   readFile = value;
  //   readFile.remove(' ');
  //   for(String line in readFile){
  //     List<String> splitLine = line.split('///');
  //     emails.add(splitLine[1]);
  //   }
  // });

  // final user = await GoogleAuthApi.signIn();

  if (user == null) return;

  final email = user.email;
  final auth = await user.authentication;
  final token = auth.accessToken!;

  final smtpServer = gmailSaslXoauth2(email, token);

  Position location = await Geolocator.getCurrentPosition();

  // List<Mail> mailContentList = await EmailDatabase.instance.readAllMails();
  Box<Mail> mailBox = Boxes.getEmail();
  String mailContent;
  mailBox.get('email') == null
      ? mailContent = 'The sender of this message is in an emergency'
      : mailContent = mailBox.get('email')!.mail.toString();

  if (mailBox.get('email')!.location) {
    mailContent = mailContent +
        "\nthis is my current location\nhttps://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}";
  } else {
    print('The location was not enabled');
  }

  List<Address> adds = [];

  Box<Contact> contactBox = Boxes.getContacts();
  List<Contact> emails = contactBox.values.toList();

  for (Contact emailInstance in emails) {
    print(emailInstance);
    adds.add(Address(emailInstance.email.trim()));
  }

  final message = Message()
    ..from = Address(email, 'Safety Application')
    ..recipients.addAll(adds)
    ..subject = 'Mail from Safety Application'
    ..text = mailContent;

  try {
    await send(message, smtpServer);

    print("the message was sent");
  } on MailerException catch (e) {
    print(e);
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference emergencyCollection = firestore.collection('emergency');
  await emergencyCollection.add({
    'email': email,
    'location': new GeoPoint(location.latitude, location.longitude),
    'time': DateTime.now(),
  });
}

Widget HomePageOld(BuildContext context, user) {
  return Container(
    height: MediaQuery.of(context).size.height,
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/blue.jpg"),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(45), topRight: Radius.circular(45)),
        color: Colors.black54),
    child: Padding(
      padding: EdgeInsets.all(30),
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //Video button
          OutlinedButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Videos()));
              },
              child: Text("To videos"),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0))),
              )),
          OutlinedButton(
              onPressed: () {
                sendEmail(user);
              },
              child: Text("Send email"),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0))),
              )),
          OutlinedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Contacts()));
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
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0))),
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
          OutlinedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ConfigMail()));
              },
              child: Text("Customise Email"),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0))),
              )),
        ],
      )),
    ),
  );
}

Widget HomePageNew(BuildContext context, user) {
  return Container(
    width: 428,
    height: 926,
    color: Color(0xff060606),
    padding: const EdgeInsets.only(
      bottom: 80,
    ),
    child: Stack(
      children: [
        SizedBox(
          height: 250,
          width: double.infinity,
          child: Image.asset(
            'assets/Images/Main-screen-vector.png',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Positioned(
            bottom: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Positioned.fill(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //app bar

                        //videos
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Videos()));
                          },
                          child: Container(
                            width: 218,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(48),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xff27e1e6), Color(0xffaa64ea)],
                              ),
                            ),
                            padding: const EdgeInsets.only(
                              left: 32,
                              right: 16,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Videos",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 24),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.video_collection,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),

                        //Send email
                        GestureDetector(
                          onTap: () {
                            sendEmail(user);
                          },
                          child: Container(
                            width: 218,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(48),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xff27e1e6), Color(0xffaa64ea)],
                              ),
                            ),
                            padding: const EdgeInsets.only(
                              left: 32,
                              right: 16,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Send Email",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 24),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.email, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),

                        //edit contacts
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Contacts()));
                          },
                          child: Container(
                            width: 218,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(48),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xff27e1e6), Color(0xffaa64ea)],
                              ),
                            ),
                            padding: const EdgeInsets.only(
                              left: 32,
                              right: 16,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Edit Contacts",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 24),
                                Container(
                                  width: 20,
                                  height: 20,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Icon(Icons.contacts_rounded,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        //emergency message
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ConfigMail()));
                          },
                          child: Container(
                            width: 218,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(48),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xff27e1e6), Color(0xffaa64ea)],
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Emergency Message",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
