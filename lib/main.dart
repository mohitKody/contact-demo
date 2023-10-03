import 'dart:io';

import 'package:contact_demo/contact_manager.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:external_path/external_path.dart' as ExtStorage;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getContact();
    super.initState();
  }

  TextEditingController controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Contact demo home page"),
      ),
      body: Center(
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.search),
              title: TextField(
                controller: controller,
                decoration: InputDecoration(
                    hintText: 'Search contacts', border: InputBorder.none),
                onChanged: onSearchTextChanged,
              ),
              trailing: IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () {
                  controller.clear();
                  FocusScope.of(context).unfocus();
                  onSearchTextChanged('');
                },
              ),
            ),
            Expanded(
                child: searchedTap == false
                    ? ListView.separated(
                        itemCount: contacts.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20.0, horizontal: 15),
                              child: Row(
                                children: [
                                  Text('${index + 1}'),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '${contacts[index + 1].displayName}'),
                                      Text(
                                          '${contacts[index + 1].phones![0].value}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 18.0),
                            child: Container(
                              height: 0.5,
                              color: Colors.deepPurple,
                            ),
                          );
                        },
                      )
                    : searchedContacts.isEmpty
                        ? const Center(
                          child: Text(
                              'No contact found',
                              style: TextStyle(color: Colors.black, fontSize: 20),
                            ),
                        )
                        : ListView.separated(
                            itemCount: searchedContacts.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0, horizontal: 15),
                                  child: Row(
                                    children: [
                                      Text('${index + 1}'),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              '${searchedContacts[index].displayName}'),
                                          Text(searchedContacts[index]
                                                  .phones!
                                                  .isNotEmpty
                                              ? '${searchedContacts[index].phones![0].value}'
                                              : ''),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0),
                                child: Container(
                                  height: 0.5,
                                  color: Colors.deepPurple,
                                ),
                              );
                            },
                          )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  List<Contact> contacts = [];
  List<Contact> searchedContacts = [];
  bool searchedTap = false;

  Future<void> getContact() async {
    ContactManager.instance.getContactPermission().then((value) {
      if (value == PermissionStatus.granted) {
        ContactManager.instance.getLocalContacts(context).then((value) async {
          contacts = value;
          print(contacts.length);

          setState(() {});
          List<List<dynamic>> rows = [];

          List<dynamic> row = [];
          row.add("Display Name");
          row.add("Middle Name");
          row.add("Contact");
          rows.add(row);
          for (int i = 1; i < contacts.length; i++) {
            List<dynamic> row = [];
            row.add(contacts[i].displayName);
            row.add(contacts[i].middleName);
            row.add(contacts[i].phones![0].value);

            rows.add(row);
          }

          Directory directory = Directory('');
          if (Platform.isAndroid) {
            directory = Directory('/storage/emulated/0/Download');
          } else {
            directory = await getApplicationDocumentsDirectory();
          }
          final exPath = directory.path;
          // final path= await Directory(exPath).create(recursive: true);
          final File file = File('$exPath/my_file.csv');

          final res = const ListToCsvConverter().convert(rows);

          file.writeAsString(res);

          print(file.path);
        });
      }
    });
  }

  onSearchTextChanged(String text) async {
    setState(() {
      searchedTap = true;
    });

    searchedContacts.clear();
    if (text.isEmpty) {
      setState(() {
        searchedTap = false;
      });
      return;
    }
    contacts.forEach((contactDetail) {
      if (contactDetail.displayName!.contains(text) ||
          contactDetail.familyName!.contains(text)) {
        searchedContacts.add(contactDetail);
      }
    });

    setState(() {});
  }

}
