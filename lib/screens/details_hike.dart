import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hike_app/model/hike.dart';
import 'package:hike_app/model/observation.dart';
import 'package:hike_app/screens/details_observation.dart';
import 'package:hike_app/screens/home.dart';
import 'package:hike_app/screens/map_page.dart';
import 'package:hike_app/service/database_helper.dart';

class details_hike extends StatefulWidget {
  int hike_id;

  details_hike({super.key, required this.hike_id});

  @override
  State<details_hike> createState() => _details_hikeState();
}

class _details_hikeState extends State<details_hike> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  Hike? hike;
  List<Observation> observations = [];
  bool? is_edit;

  @override
  void initState() {
    super.initState();

    databaseHelper.getHikeById(widget.hike_id).then((retrievedHike) {
      if (retrievedHike != null) {
        setState(() {
          hike = retrievedHike;
        });
      }
    });
    fetchObservationsForHike(widget.hike_id);
  }

  Future<void> fetchObservationsForHike(int hikeId) async {
    List<Observation> fetchObservations =
        await databaseHelper.getAllObservationsByHikeId(hikeId);
    setState(() {
      observations = fetchObservations;
    });
  }

  Future<void> delete_hike(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete Hike'),
          content: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('Are you sure to delete this hike?')]),
          actions: [
            TextButton(
              onPressed: () async {
                await databaseHelper.deleteHike(widget.hike_id);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Delete hike success!"),
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
        leading: IconButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Home()));
          },
          icon: Icon(Icons.home),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(hike?.hikeName ?? 'Unknown'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                is_edit = true;
              });
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => map_page(
                            hike_id: widget.hike_id,
                            is_edit: is_edit,
                          )));
            },
            icon: Icon(Icons.edit),
            color: Colors.blue,
          ),
          IconButton(
            onPressed: () {
              delete_hike(context);
            },
            icon: Icon(Icons.delete),
            color: Colors.red,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      'Hike name: ',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Text(hike?.hikeName ?? 'Unknown')
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('Hike description: ',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    Expanded(child: Text(hike?.description ?? 'Unknown'))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('From: ',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    Expanded(child: Text(hike?.locationFrom ?? 'Unknown'))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('To: ',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    Expanded(child: Text(hike?.locationTo ?? 'Unknown'))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('Hike distance: ',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    Text('${hike?.length ?? 'Unknown'} km')
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('Hike duration: ',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    Text('${hike?.duration ?? 'Unknown'} hour')
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('Hike date: ',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    Text(hike?.date ?? 'Unknown')
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('Level: ',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    Text(hike?.level ?? 'Unknown')
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('Is parking: ',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    Text(hike?.is_parking ?? 'Unknown')
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'All observation in hiking',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              observations.isEmpty
                  ? Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        'No observation of hiking !',
                        style: TextStyle(fontSize: 16),
                      ))
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, mainAxisExtent: 190),
                      itemCount: observations.length,
                      itemBuilder: (context, index) {
                        final observation = observations[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        details_observation(
                                          ob_id : observation.obId,
                                          hike_id : widget.hike_id
                                        )));
                          },
                          child: Stack(
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: observation.obImage.isNotEmpty
                                    ? Image.file(
                                        File(observation.obImage),
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
                                padding:
                                    const EdgeInsets.only(top: 110, right: 25),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      observation.obTime,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 155),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      observation.obName,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    )
            ],
          ),
        )),
      ),
    );
  }
}
