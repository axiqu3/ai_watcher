import 'dart:convert';

import 'package:ai_watcher/Staff/staff_home.dart';
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
      home: view_candidates(title: 'View Candidates'),
    );
  }
}

class view_candidates extends StatefulWidget {
  const view_candidates({super.key, required this.title});
  final String title;

  @override
  State<view_candidates> createState() => _view_candidatesState();
}

class _view_candidatesState extends State<view_candidates> {
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
      String apiUrl = '$urls/view_candidates/';

      var response = await http.post(Uri.parse(apiUrl), body: {});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'id': item['id'].toString(),
            'name': item['name'].toString(),
            'email': item['email'].toString(),
            'gender': item['gender'].toString(),
            'phoneno': item['phoneno'].toString(),
            'place': item['place'].toString(),
            'state': item['state'].toString(),
            'city': item['city'].toString(),
            'dob': item['dob'].toString(),
            'pin': item['pin'].toString(),
            'photo': img + item['photo'].toString(),
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
            MaterialPageRoute(builder: (context) => const staff_home()),
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
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user['photo']),
                    radius: 30,
                  ),
                  title: Text(user['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name: ${user['name']}"),
                      Text("email: ${user['email']}"),
                      Text("gender: ${user['gender']}"),
                      Text("phoneno: ${user['phoneno']}"),
                      Text("place: ${user['place']}"),
                      Text("state: ${user['state']}"),
                      Text("city: ${user['city']}"),
                      Text("dob: ${user['dob']}"),
                      Text("pin: ${user['pin']}"),
                      Text("dob: ${user['dob']}"),
                      // Text("photo: ${user['photo']}"),

                    ],


                  ),
                ),
              );
            },
          ),
        ));
  }
}
