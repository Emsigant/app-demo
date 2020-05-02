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
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '学习 Flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<User>> futureUserList;
  Future<List<Post>> futurePostList;

  @override
  void initState() {
    super.initState();
    futureUserList = fetchUserList();
    futurePostList = fetchPostList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: Drawer(
          child: DrawerHeader(
            child: Text('drawer头部'),
          ),
        ),
        appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                  icon: Icon(
                Icons.directions_car,
              )),
              Tab(
                  icon: Icon(
                Icons.directions_transit,
              )),
            ],
          ),
        ),
        body: TabBarView(children: [
          Container(
            child: FutureBuilder<List<User>>(
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
                          title: Text(item.name),
                        ),
                        onTap: () {
                          Navigator.push(_, _createRoute(item, false));
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error');
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          Container(
            child: FutureBuilder<List<Post>>(
              future: futurePostList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final list = snapshot.data;
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, index) {
                      final item = list[index];
                      return GestureDetector(
                        child: ListTile(
                          title: Text(item.title),
                        ),
                        onTap: () {
                          Navigator.push(_, _createRoute(item, true));
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error');
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ]), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}

List<User> fronUserJSON(String jsonString) {
  List<User> newList = [];
  List<dynamic> list = json.decode(jsonString);
  list.forEach((l) {
    newList.add(new User(
      id: l['id'],
      name: l['name'],
      username: l['username'],
      email: l['email'],
      address: new Address(
        street: l['address']['street'],
        suite: l['address']['suite'],
        city: l['address']['city'],
        zipcode: l['address']['zipcode'],
        geo: new Geo(
          lat: l['address']['geo']['lat'],
          lng: l['address']['geo']['lng'],
        ),
      ),
      phone: l['phone'],
      website: l['website'],
      company: new Company(
        name: l['company']['name'],
        catchPhrase: l['company']['catchPhrase'],
        bs: l['company']['bs'],
      ),
    ));
  });
  return newList;
}

List<Post> fromPostJSON(String jsonStr) {
  List<Post> newList = [];
  List<dynamic> list = json.decode(jsonStr);
  list.forEach((l) {
    newList.add(new Post(
      id: l['id'],
      userId: l['userId'],
      title: l['title'],
      body: l['body'],
    ));
  });
  return newList;
}

Future<List<User>> fetchUserList() async {
  final url = 'https://jsonplaceholder.typicode.com/users';
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return fronUserJSON(response.body);
    } else {
      throw Exception('Failed to fetch user list');
    }
  } catch (err) {
    throw Exception(err);
  }
}

Future<List<Post>> fetchPostList() async {
  final url = 'https://jsonplaceholder.typicode.com/posts';
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return fromPostJSON(response.body);
    } else {
      throw Exception('Failed to fetch user list');
    }
  } catch (err) {
    throw Exception(err);
  }
}

Route _createRoute(dynamic item, bool isPost) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Page2(
            item: item,
            isPost: isPost,
          ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.easeInOut;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      });
}

class Page2 extends StatefulWidget {
  Page2({Key key, this.item, this.isPost}) : super(key: key);

  final dynamic item;
  final bool isPost;

  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  dynamic item;
  bool isPost = false;

  @override
  void initState() {
    super.initState();
    item = widget.item;
    isPost = widget.isPost;
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(title: Text('Item detail')),
      body: Container(
          child: Column(
        children: isPost
            ? [
                Container(
                  child: Text(
                    item.title,
                    style: TextStyle(fontSize: 20.0),
                  ),
                  padding: EdgeInsets.all(12.0),
                ),
                Container(
                    padding: EdgeInsets.all(12.0), child: Text(item.body)),
              ]
            : [
                Text('id: ${item.id}'),
                Text('name: ${item.name}'),
              ],
        crossAxisAlignment: CrossAxisAlignment.start,
      )),
    );
  }
}

class User {
  int id;
  String name;
  String username;
  String email;
  Address address;
  String phone;
  String website;
  Company company;
  User(
      {this.id,
      this.name,
      this.username,
      this.email,
      this.address,
      this.phone,
      this.website,
      this.company});
}

class Address {
  String street;
  String suite;
  String city;
  String zipcode;
  Geo geo;
  Address({this.street, this.suite, this.city, this.zipcode, this.geo});
}

class Geo {
  String lat;
  String lng;
  Geo({this.lat, this.lng});
}

class Company {
  String name;
  String catchPhrase;
  String bs;
  Company({this.name, this.catchPhrase, this.bs});
}

class Post {
  int userId;
  int id;
  String title;
  String body;
  Post({this.userId, this.id, this.title, this.body});
}
