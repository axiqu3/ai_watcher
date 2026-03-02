import 'dart:convert';

import 'package:ai_watcher/Staff/add_question.dart';
import 'package:ai_watcher/Staff/staff_home.dart';
import 'package:ai_watcher/Staff/view_question.dart';
// import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'candidate_home.dart';



void main() {
  runApp(const ViewHouseApp());
}

class ViewHouseApp extends StatelessWidget {
  const ViewHouseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: viewexam(title: 'View Users'),
    );
  }
}

class viewexam extends StatefulWidget {
  const viewexam({super.key, required this.title});
  final String title;

  @override
  State<viewexam> createState() => _viewexamState();
}

class _viewexamState extends State<viewexam> {
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    viewUsers("");
  }

  Future<void> viewUsers(String searchValue) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      // String img = sh.getString('img_url') ?? '';
      String lid = sh.getString('lid').toString();
      String apiUrl = '$urls/candidateviewexam/';

      var response = await http.post(Uri.parse(apiUrl), body: {
        'lid':lid
      });
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'id': item['id'].toString(),
            'exam': item['exam'].toString(),
            'examname': item['examname'].toString(),
            'startdate': item['startdate'].toString(),
            'starttime': item['starttime'].toString(),
            'enddate':  item['enddate'].toString(),
            'endtime':  item['endtime'].toString(),
          });
        }
        setState(() {
          users = tempList;
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
        MaterialPageRoute(builder: (context) => const CandidateHome()),
      );
      return false; // Prevent default pop
    },
    child:Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 232, 177, 61),
        title: Text('Search by examname'),
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
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.all(10),
            elevation: 5,
            child: ListTile(
              // leading: CircleAvatar(
              //   backgroundImage: NetworkImage(user['photo']),
              //   radius: 30,
              // ),
              title: Text(user['examname'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Text("examname: ${user['examname']}"),
                  Text("startdate: ${user['startdate']}"),
                  Text("starttime: ${user['starttime']}"),
                  Text("enddate: ${user['enddate']}"),
                  Text("endtime: ${user['endtime']}"),
                  SizedBox(height: 20,),
                  ElevatedButton(onPressed: ()async{

                    SharedPreferences sh = await SharedPreferences.getInstance();
                    String url = sh.getString('url').toString();
                    String lid = sh.getString('lid').toString();

                    final urls = Uri.parse('$url/usersentexamrequest/');
                    try {
                      final response = await http.post(urls, body: {
                        'lid': lid,
                        'eid': user['id'].toString(),
                      });
                      if (response.statusCode == 200) {
                        Fluttertoast.showToast(msg: 'helooo');

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CandidateHome()),
                        );

                      } else {
                        Fluttertoast.showToast(msg: 'Network Error');
                      }
                    } catch (e) {
                      Fluttertoast.showToast(msg: e.toString());
                    }

                  }, child: Text('Request'))


                ],
              ),
            ),
          );
        },
      ),
    ));
  }
}
