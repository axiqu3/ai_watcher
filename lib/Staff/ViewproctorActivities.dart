import 'dart:convert';

import 'package:ai_watcher/Staff/add_question.dart';
import 'package:ai_watcher/Staff/edit_question.dart';
import 'package:ai_watcher/Staff/staff_home.dart';
// import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ViewHouseApp());
}

class ViewHouseApp extends StatelessWidget {
  const ViewHouseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: viewproctoractivities(title: 'View Users'),
    );
  }
}

class viewproctoractivities extends StatefulWidget {
  const viewproctoractivities({super.key, required this.title});
  final String title;

  @override
  State<viewproctoractivities> createState() => _viewproctoractivitiesState();
}

class _viewproctoractivitiesState extends State<viewproctoractivities> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<String> nameSuggestions = [];

  @override
  void initState() {
    super.initState();
    viewUsers("");
  }

  Future<void> viewUsers(String searchValue) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String img = sh.getString('img_url') ?? '';
      String exam = sh.getString('eid') ?? '';
      String apiUrl = '$urls/viewproctoractivities/';

      var response = await http.post(Uri.parse(apiUrl), body: {'exam': exam});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'id': item['id'],
            'date': item['date'],
            'activitytype': item['activitytype'],
            'activity': item['activity'],
            'user': item['user'],
          });
        }
        setState(() {
          users = tempList;
          filteredUsers = tempList
              .where((user) => user['question']
                  .toString()
                  .toLowerCase()
                  .contains(searchValue.toLowerCase()))
              .toList();
          nameSuggestions =
              users.map((e) => e['question'].toString()).toSet().toList();
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const staff_home()),
          );
          return false; // Prevent default pop
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 232, 177, 61),
            title: Text('Search by name'),
            // suggestions: nameSuggestions,
            // onSearch: (value) {
            //   setState(() {
            //     filteredUsers = users
            //         .where((user) => user['name']
            //         .toString()
            //         .toLowerCase()
            //         .contains(value.toLowerCase()))
            //         .toList();
            //   });
            // },
          ),
          body: ListView.builder(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 5,
                child: ListTile(

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("date: ${user['date']}"),
                      Text("activitytype: ${user['activitytype']}"),
                      Text("activity: ${user['activity']}"),
                      Text("user: ${user['user']}"),

                    ],
                  ),
                ),
              );
            },
          ),

        ));
  }
}
