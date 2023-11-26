import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hike_app/model/observation.dart';
import 'package:hike_app/screens/add_ob_page.dart';
import 'package:hike_app/screens/details_hike.dart';
import 'package:hike_app/service/database_helper.dart';

class details_observation extends StatefulWidget {
  int ob_id;
  int? hike_id;
  details_observation({super.key, required this.ob_id, this.hike_id});

  @override
  State<details_observation> createState() => _details_observationState();
}

class _details_observationState extends State<details_observation> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  Observation? obs;
  bool? is_edit;

  @override
  void initState() {
    databaseHelper.getObservationById(widget.ob_id).then((retrievedOb) {
      if (retrievedOb != null) {
        setState(() {
          obs = retrievedOb;
        });
      }
    });
    super.initState();
  }

  Future<void> delete_ob(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete Observation'),
          content: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('Are you sure to delete this observation?')]),
          actions: [
            TextButton(
              onPressed: () async {
                await databaseHelper.deleteObservation(widget.ob_id);
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
                    builder: (context) => details_hike(
                      hike_id: widget.hike_id!,
                    ),
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
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        details_hike(hike_id: widget.hike_id!)));
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        centerTitle: true,
        title: Text(obs?.obName ?? 'Unknown'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                is_edit = true;
              });
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => add_ob_page(
                            ob_id: widget.ob_id,
                            is_edit: is_edit,
                            hike_id: widget.hike_id!,
                          )));
            },
            icon: Icon(Icons.edit),
            color: Colors.blue,
          ),
          IconButton(
            onPressed: () {
              delete_ob(context);
            },
            icon: Icon(Icons.delete),
            color: Colors.red,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: obs?.obImage != null
                      ? Image.file(
                          File(obs!.obImage),
                          fit: BoxFit.fill,
                        )
                      : SizedBox()),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Name observation: ',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      obs?.obName ?? 'Unknown',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      ' at: ',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      obs?.obTime ?? 'Unknown',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [

              //   ],
              // ),
            ],
          ),
        )),
      ),
    );
  }
}
