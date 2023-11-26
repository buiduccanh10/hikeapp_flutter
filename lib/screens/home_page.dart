import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hike_app/model/hike.dart';
import 'package:hike_app/model/observation.dart';
import 'package:hike_app/screens/details_hike.dart';
import 'package:hike_app/screens/map_page.dart';
import 'package:hike_app/screens/search_hike_page.dart';
import 'package:hike_app/screens/see_all_ob_page.dart';
import 'package:hike_app/screens/see_all_hike_page.dart';
import 'package:hike_app/service/database_helper.dart';

class home_page extends StatefulWidget {
  const home_page({super.key});

  @override
  State<home_page> createState() => _home_pageState();
}

class _home_pageState extends State<home_page> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Hike> hikes = [];
  List<int> allHikeIds = [];
  Map<int, String> observationImageMap = {};
  int? hike_count;
  int? ob_count;
  double? dis_count;
  double? dur_count;
  int? energy = 0;

  @override
  void initState() {
    getDistanceCount();
    getDurationCount();
    getHikeCount();
    getObCount();
    fetchAllHike();
    super.initState();
  }

  Future<void> getDurationCount() async {
    double result = await databaseHelper.getTotalHikingDuration();
    setState(() {
      dur_count = result;
    });
  }

  Future<void> getDistanceCount() async {
    double result = await databaseHelper.getTotalHikingDistance();
    setState(() {
      dis_count = result;
    });
  }

  Future<void> getObCount() async {
    int result = await databaseHelper.getObservationCount();
    setState(() {
      ob_count = result;
    });
  }

  Future<void> getHikeCount() async {
    int result = await databaseHelper.getHikeCount();
    setState(() {
      hike_count = result;
    });
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

  @override
  Widget build(BuildContext context) {
    energy = (hike_count ?? 0) + (ob_count ?? 0);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // shape: Border(bottom: BorderSide(color: Colors.orange, width: 10)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              bottom: new Radius.elliptical(
                  MediaQuery.of(context).size.width, 70.0)),
        ),

        elevation: 0,
        toolbarHeight: 190,
        centerTitle: true,
        title: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/avt.jpeg'),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text('Bui Duc Canh', style: TextStyle(fontSize: 24)),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_activity_outlined),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'Energy points',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            Text(
              '$energy',
              style: TextStyle(color: Colors.amber),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Quick start',
                      style:
                          TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.deepOrangeAccent,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => map_page(),
                              ));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.map),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('Find map'),
                              ],
                            ),
                            Icon(Icons.navigate_next)
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => map_page(),
                              ));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.compass_calibration),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('Plan hiking'),
                              ],
                            ),
                            Icon(Icons.navigate_next)
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => search_hike_page()));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.search),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('Search hiking'),
                              ],
                            ),
                            Icon(Icons.navigate_next)
                          ],
                        ),
                      ),
                    )
                  ]),
                ),
                SizedBox(
                  height: 10,
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Hike manage',
                          style: TextStyle(
                              fontSize: 23, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Wrap(spacing: 14, runSpacing: 10, children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => see_all_hike_page()));
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2 - 15,
                          height: 100,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.golf_course),
                                Text(
                                  'Total hiking',
                                ),
                                Text(
                                  '$hike_count',
                                  style: TextStyle(fontSize: 24),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => see_all_ob_page()));
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2 - 15,
                          height: 100,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.remove_red_eye),
                                Text('Total hiking observation'),
                                Text(
                                  '$ob_count',
                                  style: TextStyle(fontSize: 24),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2 - 15,
                        height: 100,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.roundabout_left),
                              Text('Total hiking distance'),
                              Text('$dis_count ' + 'Km',
                                  style: TextStyle(fontSize: 24))
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2 - 15,
                        height: 100,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.timelapse),
                              Text('Total hiking duration'),
                              Text('$dur_count' + ' Hour',
                                  style: TextStyle(fontSize: 24))
                            ],
                          ),
                        ),
                      ),
                    ])
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent',
                          style: TextStyle(
                              fontSize: 23, fontWeight: FontWeight.w500),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => see_all_hike_page()));
                          },
                          child: Text('See all'),
                        )
                      ],
                    ),
                    hikes.isEmpty
                        ? Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Text(
                              'No hiking yet !',
                              style: TextStyle(fontSize: 16),
                            ))
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisExtent: 165,
                              crossAxisSpacing: 15,
                              crossAxisCount: 2,
                            ),
                            itemCount: hikes.length,
                            itemBuilder: (context, index) {
                              final hike = hikes[index];
                              final observationImagePath =
                                  observationImageMap[hike.id];
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
                                      padding: const EdgeInsets.only(
                                          top: 90, left: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.amber[800],
                                          borderRadius:
                                              BorderRadius.circular(5),
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
                )
              ],
            ),
          ),
        ])),
      ),
    );
  }
}
