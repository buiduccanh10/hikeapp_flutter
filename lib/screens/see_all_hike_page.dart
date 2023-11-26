import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hike_app/model/hike.dart';
import 'package:hike_app/model/observation.dart';
import 'package:hike_app/screens/details_hike.dart';
import 'package:hike_app/screens/home.dart';
import 'package:hike_app/service/database_helper.dart';

class see_all_hike_page extends StatefulWidget {
  const see_all_hike_page({super.key});

  @override
  State<see_all_hike_page> createState() => _see_all_hike_pageState();
}

class _see_all_hike_pageState extends State<see_all_hike_page> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Hike> hikes = [];
  List<int> allHikeIds = [];
  Map<int, String> observationImageMap = {};

  @override
  void initState() {
    fetchAllHike();
    super.initState();
  }

  Future<void> fetchAllHike() async {
    List<Hike> fetchHike = await databaseHelper.getAllHikes();
    setState(() {
      hikes = fetchHike;
    });
    allHikeIds = hikes.map((hike) => hike.id).toList();
    print(allHikeIds);
    for (int hikeId in allHikeIds) {
      String observationImageUrl = await fetchLatestObservationImage(hikeId);
      observationImageMap[hikeId] = observationImageUrl;
      print(observationImageMap);
    }
  }

  Future<String> fetchLatestObservationImage(int hikeId) async {
    Observation? latestObservation =
        await databaseHelper.getLatestObservationByHikeId(hikeId);

    if (latestObservation != null) {
      String observationImageUrl = getObservationImageUrl(latestObservation);
      return observationImageUrl;
    }
    return '';
  }

  String getObservationImageUrl(Observation observation) {
    return observation.obImage;
  }

  Future<void> delete_all_hike(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete All Hike'),
          content: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('Are you sure to delete all hike?')]),
          actions: [
            TextButton(
              onPressed: () async {
                await databaseHelper.deleteAllHikesAndObservations();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Deleted all hike success!"),
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
        title: Text('All hiking'),
        actions: [
          IconButton(
            onPressed: () {
              delete_all_hike(context);
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
          hikes.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 300),
                  child: Center(
                    child: Text(
                      'No hiking not yet !',
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
                  itemCount: hikes.length,
                  padding: EdgeInsets.only(top: 15, left: 10),
                  itemBuilder: (context, index) {
                    final hike = hikes[index];
                    final observationImagePath = observationImageMap[hike.id];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => details_hike(
                                      hike_id: hike.id,
                                    )));
                      },
                      child: Stack(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: observationImagePath != null &&
                                    observationImagePath.isNotEmpty
                                ? Image.file(
                                    File(observationImagePath),
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
                                  hike.hikeName,
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
                              hike.date,
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
