import 'dart:convert';

import 'package:ai_watcher/Staff/staff_home.dart';
import 'package:ai_watcher/Staff/viewallocatedexam.dart';
// import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/material.dart';
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
      home: StaffViewMark(title: 'View Users'),
    );
  }
}

class StaffViewMark extends StatefulWidget {
  const StaffViewMark({super.key, required this.title});
  final String title;

  @override
  State<StaffViewMark> createState() => _StaffViewMarkState();
}

class _StaffViewMarkState extends State<StaffViewMark> {
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
      String eid = sh.getString('eid') ?? '';
      String apiUrl = '$urls/Staffviewmark/';

      var response = await http.post(Uri.parse(apiUrl), body: {
        'eid':eid
      });
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'id': item['id'],
            'user': item['user'],
            'exam': item['exam'],
            'mark': item['mark'],
          });
        }
        setState(() {
          users = tempList;
          filteredUsers = tempList
              .where((user) =>
              user['name']
                  .toString()
                  .toLowerCase()
                  .contains(searchValue.toLowerCase()))
              .toList();
          nameSuggestions = users.map((e) => e['name'].toString()).toSet().toList();
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
        MaterialPageRoute(builder: (context) => const viewallocatedexam(title: '',)),
      );
      return false; // Prevent default pop
    },
    child:Scaffold(
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
                  Text("user: ${user['user']}"),
                  Text("exam: ${user['exam']}"),
                  Text("mark: ${user['mark']}"),
                ],
              ),
            ),
          );
        },
      ),
    ));
  }
}
