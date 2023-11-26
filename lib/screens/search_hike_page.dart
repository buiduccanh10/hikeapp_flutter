import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hike_app/model/hike.dart';
import 'package:hike_app/model/observation.dart';
import 'package:hike_app/screens/details_hike.dart';
import 'package:hike_app/service/database_helper.dart';

class search_hike_page extends StatefulWidget {
  const search_hike_page({super.key});

  @override
  State<search_hike_page> createState() => _search_hike_pageState();
}

class _search_hike_pageState extends State<search_hike_page> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Hike> hikes = [];
  List<int> allHikeIds = [];
  Map<int, String> observationImageMap = {};
  String searchQuery = '';

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

  void filterHikes(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  List<Hike> getFilteredHikes() {
    if (searchQuery.isEmpty) {
      return hikes;
    } else {
      return hikes.where((hike) {
        final name = hike.hikeName.toLowerCase();
        final date = hike.date.toLowerCase();
        final query = searchQuery.toLowerCase();
        return name.contains(query) ||
            name.replaceAll(' ', '').contains(query) ||
            date.contains(query) ||
            date.replaceAll('-', '').contains(query);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Hike> filteredHikes = getFilteredHikes();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Search'),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
          child: Column(
        children: [
          Padding(
            padding:
                EdgeInsets.only(top: 20.0, left: 10, right: 10, bottom: 20),
            child: SearchBar(
              overlayColor: MaterialStateProperty.all(Colors.blueAccent),
              hintText: 'Search name, date hiking...',
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.search),
              ),
              onChanged: filterHikes,
            ),
          ),
          filteredHikes.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 300),
                  child: Center(
                    child: Text(
                      'No hiking to search !',
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
                  itemCount: filteredHikes.length,
                  padding: EdgeInsets.only(top: 10, left: 10),
                  itemBuilder: (context, index) {
                    final hike = filteredHikes[index];
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
