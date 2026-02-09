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
      home: view_question(title: 'View Users'),
    );
  }
}

class view_question extends StatefulWidget {
  const view_question({super.key, required this.title});
  final String title;

  @override
  State<view_question> createState() => _view_questionState();
}

class _view_questionState extends State<view_question> {
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
      String exam = sh.getString('exam') ?? '';
      String apiUrl = '$urls/examinerviewquestion/';

      var response = await http.post(Uri.parse(apiUrl), body: {'exam': exam});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'id': item['id'],
            'question': item['question'],
            'option1': item['option1'],
            'option2': item['option2'],
            'option3': item['option3'],
            'option4': item['option4'],
            'answer': item['answer'],
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
                  title: Text(user['question'],
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("option1: ${user['option1']}"),
                      Text("option2: ${user['option2']}"),
                      Text("option3: ${user['option3']}"),
                      Text("option4: ${user['option4']}"),
                      Text("answer: ${user['answer']}"),
                      Row(
                        children: [
                          ElevatedButton(onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>EditQuestions(title: '',
                              question: user['question'], option1: user['option1'], option2: user['option2'], option3: user['option3'], option4: user['option4'], answer:user['answer '], id: user['id'].toString(),)));

                          }, child: Text("edit")),

                          ElevatedButton(
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
                                    Uri.parse('$url/deletequestion/');
                                var request =
                                    http.MultipartRequest('POST', uri);
                                request.fields['id'] = user['id'].toString();

                                try {
                                  var response = await request.send();
                                  var respStr =
                                      await response.stream.bytesToString();
                                  var data = jsonDecode(respStr);

                                  if (response.statusCode == 200 &&
                                      data['status'] == 'ok') {
                                    Fluttertoast.showToast(
                                        msg: "deleted successfully.");
                                    viewUsers("");
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Submission failed.");
                                  }
                                } catch (e) {
                                  Fluttertoast.showToast(msg: "Error: $e");
                                }
                              },
                              child: Text("Delete")),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => add_question(
                          title: '',
                        )));
          }),
        ));
  }
}
