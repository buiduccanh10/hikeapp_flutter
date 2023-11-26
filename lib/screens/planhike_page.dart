import 'dart:ffi';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hike_app/model/hike.dart';
import 'package:hike_app/screens/add_ob_page.dart';
import 'package:hike_app/screens/details_hike.dart';
import 'package:hike_app/screens/home.dart';
import 'package:hike_app/service/database_helper.dart';

class planhike_page extends StatefulWidget {
  String start_hike;
  String end_hike;
  String length_hike;
  String duration_hike;
  int? hike_id;
  bool? is_edit;

  planhike_page(
      {this.is_edit,
      this.hike_id,
      required this.start_hike,
      required this.end_hike,
      required this.length_hike,
      required this.duration_hike});

  @override
  State<planhike_page> createState() => _planhike_pageState();
}

class _planhike_pageState extends State<planhike_page> {
  final form_key = GlobalKey<FormState>();
  DatabaseHelper databaseHelper = DatabaseHelper();

  TextEditingController name_hike = TextEditingController();
  TextEditingController description_hike = TextEditingController();
  String selectedIsPark = "Yes";
  String isPark = "yes";
  DateTime selectedDate = DateTime.now();
  String date = "";
  String level = "Normal";
  final List<String> levelOptions = ["Very Hard", "Hard", "Normal", "Easy"];
  bool is_validate = false;

  @override
  void initState() {
    super.initState();

    if (widget.is_edit != null && widget.is_edit!) {
      Hike? hike;
      databaseHelper.getHikeById(widget.hike_id!).then((retrievedHike) {
        if (retrievedHike != null) {
          setState(() {
            hike = retrievedHike;

            name_hike.text = hike!.hikeName;
            description_hike.text = hike!.description;
            level = hike!.level;
            date = hike!.date;
            handleRadioValueChanged(hike!.is_parking);
          });
        }
      });
    }
  }

  void validateAndSave() {
    final FormState form = form_key.currentState!;
    if (form.validate()) {
      setState(() {
        is_validate = true;
      });
    } else {
      is_validate = false;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        date = "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
      });
    }
  }

  void handleRadioValueChanged(String? value) {
    if (value != null) {
      setState(() {
        selectedIsPark = value;
        isPark = (value == "Yes") ? "yes" : "no";
      });
    }
  }

  Future<void> save_hike(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: (widget.is_edit != null && widget.is_edit!)
              ? Text('Confirm Edit Hiking Information')
              : Text('Confirm Hiking Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Name: ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Expanded(child: Text('${name_hike.text}'))
                ],
              ),
              Row(
                children: [
                  Text('Description: ',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  Expanded(child: Text('${description_hike.text}'))
                ],
              ),
              Row(
                children: [
                  Text('From: ', style: TextStyle(fontWeight: FontWeight.w700)),
                  Expanded(child: Text('${widget.start_hike}'))
                ],
              ),
              Row(
                children: [
                  Text('To: ', style: TextStyle(fontWeight: FontWeight.w700)),
                  Expanded(child: Text('${widget.end_hike}'))
                ],
              ),
              Row(
                children: [
                  Text('Date: ', style: TextStyle(fontWeight: FontWeight.w700)),
                  Text('$date')
                ],
              ),
              Row(
                children: [
                  Text('Distance: ',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  Text('${widget.length_hike} ' + ' Km')
                ],
              ),
              Row(
                children: [
                  Text('Duration: ',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  Text('${widget.duration_hike} ' + ' Hour')
                ],
              ),
              Row(
                children: [
                  Text('Level: ',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  Text('$level')
                ],
              ),
              Row(
                children: [
                  Text('Is Park: ',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  Text('$isPark')
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (widget.is_edit != null && widget.is_edit!) {
                  await databaseHelper.updateHike(
                      widget.hike_id!,
                      name_hike.text,
                      description_hike.text,
                      widget.start_hike,
                      widget.end_hike,
                      date,
                      widget.length_hike,
                      widget.duration_hike,
                      level,
                      isPark);

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Edit hike success!"),
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
                } else {
                  int selectedId = await databaseHelper.planHike(
                      name_hike.text,
                      description_hike.text,
                      widget.start_hike,
                      widget.end_hike,
                      date,
                      widget.length_hike,
                      widget.duration_hike,
                      level,
                      isPark);
                  print(selectedId);

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Plan hike success!"),
                    action: SnackBarAction(
                        label: 'OK',
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        }),
                  ));

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => add_ob_page(
                        hike_id: selectedId,
                      ),
                    ),
                  );
                }
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
          title: (widget.is_edit != null && widget.is_edit!)
              ? Text('Edit Hiking')
              : Text('Plan Hiking'),
          actions: [
            TextButton(
                onPressed: () {
                  validateAndSave();
                  if (is_validate) {
                    save_hike(context);
                  }
                },
                child: Text(
                  'Done',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ))
          ],
        ),
        body: SingleChildScrollView(
          child: SafeArea(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: form_key,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Name hike'),
                    controller: name_hike,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter hike name' : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Hike description',
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLength: null,
                    maxLines: null,
                    minLines: 5,
                    controller: description_hike,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter hike description' : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'From'),
                    initialValue: widget.start_hike,
                    readOnly: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'To'),
                    initialValue: widget.end_hike,
                    readOnly: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Length of hike'),
                    initialValue: widget.length_hike + ' Km',
                    readOnly: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Duration of hike'),
                    initialValue: widget.duration_hike + ' Hour',
                    readOnly: true,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Level',
                    ),
                    value: level,
                    items: levelOptions.map((String level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text(level),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          level = newValue;
                        });
                      }
                    },
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 14.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Is there parking?',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        leading: Radio<String>(
                          value: "Yes",
                          groupValue: selectedIsPark,
                          onChanged: handleRadioValueChanged,
                        ),
                        title: Text("Yes"),
                      ),
                      ListTile(
                        leading: Radio<String>(
                          value: "No",
                          groupValue: selectedIsPark,
                          onChanged: handleRadioValueChanged,
                        ),
                        title: Text("No"),
                      ),
                    ],
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Date',
                        hintText: 'Plese select date from button'),
                    controller: TextEditingController(
                        text: date), // Display the selected date
                    readOnly: true,

                    validator: (value) => value!.isEmpty
                        ? 'Please enter date hike'
                        : null, // Prevent manual input
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Select Date'),
                  )
                ],
              ),
            ),
          )),
        ));
  }
}
