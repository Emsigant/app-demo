import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

Future<List<dynamic>> fetchUserList() async {
  final url = 'https://jsonplaceholder.typicode.com/users';
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to fetch user list');
  }
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _list = ['1', '2', '3'];

  Future<List<dynamic>> futureUserList;

  @override
  void initState() {
    super.initState();
    futureUserList = fetchUserList();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureUserList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final list = snapshot.data;
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, index) {
                final item = list[index];
                return GestureDetector(
                  child: ListTile(
                    title: Text(item['username']),
                  ),
                  onTap: () {
                    Navigator.push(_, MaterialPageRoute(builder: (_) {
                      return Scaffold(
                        appBar: AppBar(title: Text('Item $index')),
                        body: Container(
                            child: Column(
                          children: [
                            Text('id: ${item["id"]}'),
                            Text('name: ${item["name"]}'),
                            Text('username: ${item["username"]}'),
                            Text('email: ${item["email"]}'),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                        )),
                      );
                    }));
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error');
          }
          return CircularProgressIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var list = _list;
          list.add('${_list.length + 1}');
          setState(() {
            _list = list;
          });
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
