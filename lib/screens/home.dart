import 'package:flutter/material.dart';
import 'package:hike_app/screens/home_page.dart';
import 'package:hike_app/screens/map_page.dart';
import 'package:hike_app/screens/notification_page.dart';
import 'package:hike_app/screens/profile_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int index = 0;

  List<Widget> list_page = <Widget>[
    home_page(),
    map_page(),
    notification_page(),
    profile_page()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: list_page[index],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.landscape_rounded),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          )
        ],
        //backgroundColor: Colors.blue,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        iconSize: 30,
        currentIndex: index,
        onTap: route_page,
      ),
    );
  }

  void route_page(int value) {
    setState(() {
      index = value;
    });
  }
}
