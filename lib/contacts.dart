import 'dart:async';

import 'package:flutter/material.dart';

import 'package:safety_application/models/contacts_model.dart';
import 'functions.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'boxes.dart';
import 'GradientText.dart';

class Contacts extends StatelessWidget {
  const Contacts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ContactsStateFull());
  }
}

class ContactsStateFull extends StatefulWidget {
  const ContactsStateFull({Key? key}) : super(key: key);

  @override
  _ContactsStateFullState createState() => _ContactsStateFullState();
}

class _ContactsStateFullState extends State<ContactsStateFull>
    with SingleTickerProviderStateMixin {
  List<String> readFile = [];
  TextEditingController contactNameInput = TextEditingController();
  TextEditingController contactEmailInput = TextEditingController();
  TextEditingController contactNumberInput = TextEditingController();
  late AnimationController _keyboardController;
  late Animation<double> _animation;
  FocusNode textFocus = FocusNode();
  bool addContact = false;
  List<Contact>? contacts = null;
  bool isLoading = false;
  bool updateScreen = false;
  late Box contactsBox;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _keyboardController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 30));

    _animation = Tween<double>(begin: 0, end: 300).animate(_keyboardController)
      ..addListener(() {
        setState(() {
          // The state that has changed here is the animation object’s value.
        });
      });

    _keyboardController.forward();

    textFocus.addListener(_onFocusChange);

    _getContactsBox();

    // widget.storage.readData().then((List<String> value) {
    //   setState(() {
    //     readFile = value;
    //   });
    //   readFile.remove(' ');
    // });
  }

  void _onFocusChange() {
    _keyboardController.forward();
    // print(_keyboardController.status);
  }

  @override
  void dispose() {
    _keyboardController.dispose();
    textFocus.dispose();
    super.dispose();
  }

  int counter = 0;

  @override
  Widget build(BuildContext context) {
    counter = 0;
    return MaterialApp(
        theme: ThemeData(
          fontFamily: 'Bahnschrift',
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        home: Scaffold(
          body: Container(
            color: Colors.black,
            child: Stack(
              children: [
                ContactUI(),
                Positioned(
                  bottom: 50,
                  right: 50,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        addContact = !addContact;
                      });
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(48),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xff27e1e6), Color(0xffaa64ea)],
                        ),
                      ),
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 2, top: 2),
                        child: fabIcon(),
                      )),
                    ),
                  ),
                )
              ],
            ),
          ),

          // floatingActionButton: Container(
          //   child: FloatingActionButton(
          //     onPressed: () {
          //       setState(() {
          //         addContact = !addContact;
          //       });
          //     },
          //     child: fabIcon(),
          //   ),
        ));
  }

  Widget fabIcon() {
    if (!addContact) {
      return Stack(children: <Widget>[
        // Stroked text as border.
        Icon(
          Icons.add,
          color: Colors.black87.withAlpha(100),
          size: 42,
        ),
        // Solid text as fill.
        Icon(
          Icons.add,
          color: Colors.white,
          size: 40,
        )
      ]);
    } else {
      return Stack(children: <Widget>[
        // Stroked text as border.
        Icon(
          Icons.close,
          color: Colors.black87.withAlpha(100),
          size: 42,
        ),
        // Solid text as fill.
        Icon(
          Icons.close,
          color: Colors.white,
          size: 40,
        )
      ]);
    }
  }

  Widget EmailList() {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 30, 5, 5),
      child: Container(
          height: MediaQuery.of(context).size.height,
          child: Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: ValueListenableBuilder<Box<Contact>>(
              valueListenable: Boxes.getContacts().listenable(),
              builder: (context, box, _) {
                final contacts = box.values.toList().cast<Contact>();

                return buildEmailList(contacts);
              },
            ),
          )),
    );
  }

  Widget buildEmailList(List<Contact> contacts) {
    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        counter++;
        final contactItem = contacts[index];
        return ListTile(
            title: Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.spaceAround,
              children: [
                Text(
                    "${counter} . ${contactItem.name}\n      ${contactItem.email}",
                    style: TextStyle(fontSize: 20, color: Colors.white)),
                IconButton(
                    icon: const Icon(Icons.delete_forever),
                    tooltip: 'delete the contact from the list',
                    color: Colors.red,
                    onPressed: () {
                      contactItem.delete();
                    }),
              ]),
        ));
      },
    );
  }

  Widget EmailInput() {
    return Center(
      child: Container(
          child: Column(children: [
        TextFormField(
          controller: contactNameInput,
          focusNode: textFocus,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintStyle: TextStyle(color: Colors.white),
            hintText: 'Enter the name of the emergency contact',
          ),
        ),
        GradientText('Name of the contact',
            gradient: LinearGradient(colors: [
              Color(0xff27e1e6),
              Color(0xffaa64ea),
            ])),
      ])),
    );

    return Container(
      width: MediaQuery.of(context).size.width * 4 / 5 + 50,
      height: MediaQuery.of(context).size.height / 3 * 2,
      alignment: Alignment.center,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: TextFormField(
              controller: contactNameInput,
              focusNode: textFocus,
              decoration: InputDecoration(
                  hintText: "Enter the name of the emergency contact"),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
            child: TextFormField(
              controller: contactEmailInput,
              decoration: InputDecoration(
                  hintText: "Enter the email of the emergency contact"),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
            child: TextFormField(
              controller: contactNumberInput,
              decoration: InputDecoration(
                  hintText: "Enter the number of the emergency contact"),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              writeToDB();
              setState(() {
                addContact = false;
              });
            },
            child: Text("write the name to file"),
          )
        ]),
      ),
    );
  }

  Future writeToDB() async {
    final contact = Contact()
      ..name = contactNameInput.text
      ..email = contactEmailInput.text
      ..number = contactNumberInput.text;

    final box = Boxes.getContacts();
    box.add(contact);
  }

  Widget ContactUI() {
    if (addContact) {
      return Container(
        alignment: Alignment.center,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [EmailInput()]),
      );
    } else {
      return EmailList();
    }
  }

  Future _getContactsBox() async {
    contactsBox = await Hive.openBox<Contact>('contacts');
  }
}

// Container(
// width: MediaQuery
//     .of(context)
// .size
//     .width * 4 / 5,
// margin: EdgeInsets.only(bottom: _animation.value),
// child: Column(children: [
// Padding(
// padding: EdgeInsets.all(10),
// child: TextFormField(
// controller: contactNameInput,
// focusNode: textFocus,
// decoration: InputDecoration(
// hintText:
// "Enter the name of the emergency contact"),
// ),
// ),
// Padding(
// padding: EdgeInsets.all(10),
// child: TextFormField(
// controller: contactEmailInput,
// decoration: InputDecoration(
// hintText:
// "Enter the email of the emergency contact"),
// ),
// ),
// OutlinedButton(
// onPressed: writeToFile,
// child: Text("write the name to file"),
// )
// ])),
