import 'dart:convert';

import 'package:ai_watcher/Staff/add_question.dart';
import 'package:ai_watcher/Staff/edit_question.dart';
import 'package:ai_watcher/Staff/staff_home.dart';
import 'package:ai_watcher/chat.dart';
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
      home: ViewExamRequest(title: 'View Users'),
    );
  }
}

class ViewExamRequest extends StatefulWidget {
  const ViewExamRequest({super.key, required this.title});
  final String title;

  @override
  State<ViewExamRequest> createState() => _ViewExamRequestState();
}

class _ViewExamRequestState extends State<ViewExamRequest> {
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
      String eid = sh.getString('eid') ?? '';
      String apiUrl = '$urls/viewrequestexam/';

      var response = await http.post(Uri.parse(apiUrl), body: {'eid': eid});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'id':item['id'].toString(),
            'date': item['date'].toString(),
            'status': item['status'].toString(),
            'name': item['name'].toString(),
            'email': item['email'].toString(),
            'gender': item['gender'].toString(),
            'phoneno': item['phoneno'].toString(),
            'place': item['place'].toString(),
            'state': item['state'].toString(),
            'city': item['city'].toString(),
            'dob': item['dob'].toString(),
            'pin': item['pin'].toString(),
            'photo': img+item['photo'].toString(),
            'examname': item['examname'].toString(),
            'startdate': item['startdate'].toString(),
            'starttime': item['starttime'].toString(),
            'enddate': item['enddate'].toString(),
            'endtime': item['endtime'].toString(),
            'ulid': item['ulid'].toString(),

          });
        }
        setState(() {
          users = tempList;
          filteredUsers = tempList
              .where((user) => user['date']
              .toString()
              .toLowerCase()
              .contains(searchValue.toLowerCase()))
              .toList();
          nameSuggestions =
              users.map((e) => e['date'].toString()).toSet().toList();
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
                  // title: Text(user['question'],
                  //     style: TextStyle(fontWeight: FontWeight.bold)),
                  leading: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(user['photo']),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("name: ${user['name']}"),
                      Text("email: ${user['email']}"),
                      Text("gender: ${user['gender']}"),
                      Text("phoneno: ${user['phoneno']}"),
                      Text("place: ${user['place']}"),
                      Text("state: ${user['state']}"),
                      Text("city: ${user['city']}"),
                      Text("dob: ${user['dob']}"),
                      Text("pin: ${user['pin']}"),
                      Text("examname: ${user['examname']}"),
                      Text("startdate: ${user['startdate']}"),
                      Text("starttime: ${user['starttime']}"),
                      Text("enddate: ${user['enddate']}"),
                      Text("endtime: ${user['endtime']}"),
                      Text("date: ${user['date']}"),
                      Text("status: ${user['status']}"),


                      user['status']=='pending'?ElevatedButton(
                          onPressed: () async {
                            SharedPreferences sh =
                            await SharedPreferences.getInstance();
                            String? url = sh.getString('url');
                            String? exam = sh.getString('exam');

                            if (url == null) {
                              Fluttertoast.showToast(
                                  msg: "Server URL not found.");
                              return;
                            }

                            final uri =
                            Uri.parse('$url/approve_examrequest/');
                            var request =
                            http.MultipartRequest('POST', uri);
                            request.fields['erid'] = user['id'].toString();

                            try {
                              var response = await request.send();
                              var respStr =
                              await response.stream.bytesToString();
                              var data = jsonDecode(respStr);

                              if (response.statusCode == 200 &&
                                  data['status'] == 'ok') {
                                Fluttertoast.showToast(
                                    msg: "Approved successfully.");
                                viewUsers("");
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Submission failed.");
                              }
                            } catch (e) {
                              Fluttertoast.showToast(msg: "Error: $e");
                            }
                          },
                          child: Text("Approve")):Text(''),


                      user['status']=='pending'?ElevatedButton(
                          onPressed: () async {
                            SharedPreferences sh =
                            await SharedPreferences.getInstance();
                            String? url = sh.getString('url');
                            String? exam = sh.getString('exam');

                            if (url == null) {
                              Fluttertoast.showToast(
                                  msg: "Server URL not found.");
                              return;
                            }

                            final uri =
                            Uri.parse('$url/reject_examrequest/');
                            var request =
                            http.MultipartRequest('POST', uri);
                            request.fields['erid'] = user['id'].toString();

                            try {
                              var response = await request.send();
                              var respStr =
                              await response.stream.bytesToString();
                              var data = jsonDecode(respStr);

                              if (response.statusCode == 200 &&
                                  data['status'] == 'ok') {
                                Fluttertoast.showToast(
                                    msg: "Rejected successfully.");
                                viewUsers("");
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Submission failed.");
                              }
                            } catch (e) {
                              Fluttertoast.showToast(msg: "Error: $e");
                            }
                          },
                          child: Text("Reject")):Text(''),


                      user['status']=='Approved'?ElevatedButton(
                          onPressed: () async {
                            SharedPreferences sh =
                            await SharedPreferences.getInstance();
                            sh.setString('toid', user['ulid'].toString());
                            sh.setString('agrname', user['name'].toString());
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MyChatPage(title: '',)),
                            );
                          },
                          child: Text("Chat")):Text(''),



                      // Row(
                      //   children: [
                      //
                      //     ElevatedButton(
                      //         onPressed: () async {
                      //           SharedPreferences sh =
                      //               await SharedPreferences.getInstance();
                      //           String? url = sh.getString('url');
                      //           String? exam = sh.getString('exam');
                      //
                      //           if (url == null) {
                      //             Fluttertoast.showToast(
                      //                 msg: "Server URL not found.");
                      //             return;
                      //           }
                      //
                      //           final uri =
                      //               Uri.parse('$url/deletequestion/');
                      //           var request =
                      //               http.MultipartRequest('POST', uri);
                      //           request.fields['id'] = user['id'].toString();
                      //
                      //           try {
                      //             var response = await request.send();
                      //             var respStr =
                      //                 await response.stream.bytesToString();
                      //             var data = jsonDecode(respStr);
                      //
                      //             if (response.statusCode == 200 &&
                      //                 data['status'] == 'ok') {
                      //               Fluttertoast.showToast(
                      //                   msg: "deleted successfully.");
                      //               viewUsers("");
                      //             } else {
                      //               Fluttertoast.showToast(
                      //                   msg: "Submission failed.");
                      //             }
                      //           } catch (e) {
                      //             Fluttertoast.showToast(msg: "Error: $e");
                      //           }
                      //         },
                      //         child: Text("Approve")),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              );
            },
          ),

        ));
  }
}
