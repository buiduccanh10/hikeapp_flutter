import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hike_app/model/observation.dart';
import 'package:hike_app/screens/details_observation.dart';
import 'package:hike_app/screens/home.dart';
import 'package:hike_app/service/database_helper.dart';

class see_all_ob_page extends StatefulWidget {
  const see_all_ob_page({super.key});

  @override
  State<see_all_ob_page> createState() => _see_all_ob_pageState();
}

class _see_all_ob_pageState extends State<see_all_ob_page> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Observation> obs = [];
  List<int> allObId = [];

  @override
  void initState() {
    fetchAllHike();
    super.initState();
  }

  Future<void> fetchAllHike() async {
    List<Observation> fetchHike = await databaseHelper.getAllObservation();
    setState(() {
      obs = fetchHike;
    });
    allObId = obs.map((ob) => ob.obId).toList();
  }

  Future<void> delete_all_ob(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete All Observation'),
          content: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('Are you sure to delete all observation?')]),
          actions: [
            TextButton(
              onPressed: () async {
                await databaseHelper.deleteAllObservations();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Delete observation success!"),
                  action: SnackBarAction(
                      label: 'OK',
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      }),
                ));
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(),
                  ),
                );
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All observation'),
        actions: [
          IconButton(
            onPressed: () {
              delete_all_ob(context);
            },
            icon: Icon(
              Icons.delete_sweep,
              size: 30,
            ),
            color: Colors.red,
          )
        ],
      ),
      body: SafeArea(
          child: Column(
        children: [
          obs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 300),
                  child: Center(
                    child: Text(
                      'No observation not yet !',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisExtent: 165,
                    crossAxisSpacing: 0,
                    crossAxisCount: 2,
                  ),
                  itemCount: obs.length,
                  padding: EdgeInsets.only(top: 15, left: 10),
                  itemBuilder: (context, index) {
                    final ob = obs[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => details_observation(
                                      ob_id: ob.obId,
                                    )));
                      },
                      child: Stack(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: obs.isNotEmpty
                                ? Image.file(
                                    File(ob.obImage),
                                    height: 150,
                                    width: 200,
                                    fit: BoxFit.fill,
                                  )
                                : Image.asset(
                                    'assets/hiking.jpg',
                                    height: 150,
                                    width: 200,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 90, left: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.amber[800],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  ob.obName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 125.0,
                              left: 10.0,
                            ),
                            child: Text(
                              ob.obTime,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                )
        ],
      )),
    );
  }
}
