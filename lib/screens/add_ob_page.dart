import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hike_app/model/hike.dart';
import 'package:hike_app/model/observation.dart';
import 'package:hike_app/screens/details_observation.dart';
import 'package:hike_app/screens/home.dart';
import 'package:hike_app/screens/home_page.dart';
import 'package:hike_app/service/database_helper.dart';
import 'package:image_picker/image_picker.dart';

class add_ob_page extends StatefulWidget {
  int hike_id;
  int? ob_id;
  bool? is_edit;

  add_ob_page({super.key, required this.hike_id, this.ob_id, this.is_edit});

  @override
  State<add_ob_page> createState() => _add_ob_pageState();
}

class _add_ob_pageState extends State<add_ob_page> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  Hike? hike;
  Observation? obs;
  TextEditingController ob_name = TextEditingController();
  String ob_time = "";
  File? image;
  String ob_image_url = "";
  List<Observation> observations = [];
  bool is_list_empty = true;

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
    if (widget.is_edit != null && widget.is_edit!) {
      databaseHelper.getObservationById(widget.ob_id!).then((retrievedOb) {
        if (retrievedOb != null) {
          setState(() {
            obs = retrievedOb;
            ob_name.text = obs!.obName;
            ob_time = obs!.obTime;
            image = File(obs!.obImage);
          });
        }
      });
    }
  }

  void add_observation() {
    final observationName = ob_name.text;
    if (observationName.isEmpty || image == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Validation Error"),
            content: Text("Observation name and image are required."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }
    if (widget.is_edit != null && widget.is_edit!) {
      databaseHelper.updateObservation(
          widget.ob_id!, observationName, ob_time, ob_image_url);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => details_observation(
                    hike_id: widget.hike_id!,
                    ob_id: widget.ob_id!,
                  )));

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Observation edited!"),
        action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            }),
      ));
    } else {
      databaseHelper.addObservation(
          observationName, widget.hike_id, ob_time, ob_image_url);
      fetchObservationsForHike(widget.hike_id);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Observation added!"),
        action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            }),
      ));

      ob_name.clear();
      ob_time = '';
      image = null;
    }
  }

  Future<void> fetchObservationsForHike(int hikeId) async {
    List<Observation> fetchObservations =
        await databaseHelper.getAllObservationsByHikeId(hikeId);
    setState(() {
      observations = fetchObservations;
      is_list_empty = observations.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (widget.is_edit != null && widget.is_edit!)
          ? AppBar(
              title: Text('Edit observation'),
            )
          : AppBar(
              automaticallyImplyLeading: false,
              title: Text('Add observation'),
              actions: [
                TextButton(
                    onPressed: () {
                      if (is_list_empty) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Observation is empty"),
                              content: Text(
                                  "Are you sure to finish without observation?"),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("OK"),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Home(),
                                        ));
                                  },
                                ),
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Comfirm Observation Data!"),
                              content:
                                  Text("Are you sure to finish observation?"),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("OK"),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Home(),
                                        ));
                                  },
                                ),
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.save,
                          color: Colors.red,
                        ),
                        Text(
                          'Finish',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 24,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ))
              ],
            ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text("Hike name:",
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Text(hike != null ? hike!.hikeName : "Loading...")
                        ],
                      ),
                      Row(
                        children: [
                          Text("Hike description:",
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Expanded(
                              child: Text(hike != null
                                  ? hike!.description
                                  : "Loading..."))
                        ],
                      ),
                      Row(
                        children: [
                          Text("From:",
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Expanded(
                              child: Text(hike != null
                                  ? hike!.locationFrom
                                  : "Loading..."))
                        ],
                      ),
                      Row(
                        children: [
                          Text("To:",
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Expanded(
                              child: Text(hike != null
                                  ? hike!.locationTo
                                  : "Loading..."))
                        ],
                      ),
                      Row(
                        children: [
                          Text("Hike length:",
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Text(hike != null ? hike!.length : "Loading...")
                        ],
                      ),
                      Row(
                        children: [
                          Text("Hike duration:",
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Text(hike != null ? hike!.duration : "Loading...")
                        ],
                      ),
                      Row(
                        children: [
                          Text("Hike level:",
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Text(hike != null ? hike!.level : "Loading...")
                        ],
                      ),
                      Row(
                        children: [
                          Text("Is parking:",
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Text(hike != null ? hike!.is_parking : "Loading...")
                        ],
                      ),
                      Row(
                        children: [
                          Text("Date:",
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Text(hike != null ? hike!.date : "Loading...")
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 400,
                  height: 1,
                  decoration: BoxDecoration(color: Colors.black),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "What are you observation?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name observation'),
                  controller: ob_name,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Time observation',
                      hintText: 'Default is current time'),
                  controller: TextEditingController(text: ob_time),
                  readOnly: true,
                ),
                SizedBox(
                  height: 10,
                ),
                if (image != null)
                  Image.file(
                    image!,
                    height: 200,
                  ),
                Container(
                  width: 150,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700]),
                    onPressed: pickImage,
                    child: Row(
                      children: [
                        Icon(Icons.image),
                        Text('Select Image'),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: 190,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () {
                        add_observation();
                      },
                      child: (widget.is_edit != null && widget.is_edit!)
                          ? Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 30,
                                ),
                                Text(
                                  'Edit observation',
                                  style: TextStyle(fontSize: 16),
                                )
                              ],
                            )
                          : Row(
                              children: [
                                Icon(
                                  Icons.add,
                                  size: 30,
                                ),
                                Text(
                                  'Add observation',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            )),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: 400,
                  height: 1,
                  decoration: BoxDecoration(color: Colors.black),
                ),
                SizedBox(
                  height: 10,
                ),
                (widget.is_edit != null && widget.is_edit!)
                    ? SizedBox()
                    : Text(
                        "List observation ",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                SizedBox(
                  height: 10,
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisExtent: 170,
                    crossAxisCount: 2,
                  ),
                  itemCount: observations.length,
                  itemBuilder: (context, index) {
                    final observation = observations[index];
                    return ListTile(
                      title: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.file(
                          File(observation.obImage),
                          height: 110,
                          width: 150,
                          fit: BoxFit.fill,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Name: ${observation.obName}'),
                          Text('Time: ${observation.obTime}'),
                        ],
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    DateTime now = DateTime.now();
    DateTime timeOnly =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    String formattedTime = '${timeOnly.hour}:${timeOnly.minute}';
    // print(formattedTime);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
        ob_image_url = pickedFile.path;
        print(ob_image_url);
        ob_time = formattedTime;
      });
    }
  }
}
