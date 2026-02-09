import 'dart:convert';

import 'package:ai_watcher/Staff/ViewproctorActivities.dart';
import 'package:ai_watcher/Staff/add_question.dart';
import 'package:ai_watcher/Staff/staff_home.dart';
import 'package:ai_watcher/Staff/view_examrequest.dart';
import 'package:ai_watcher/Staff/view_marks.dart';
import 'package:ai_watcher/Staff/view_question.dart';
import 'package:ai_watcher/candidate/ViewExamRequest.dart';
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
      home: viewallocatedexam(title: 'View Users'),
    );
  }
}

class viewallocatedexam extends StatefulWidget {
  const viewallocatedexam({super.key, required this.title});
  final String title;

  @override
  State<viewallocatedexam> createState() => _viewallocatedexamState();
}

class _viewallocatedexamState extends State<viewallocatedexam> {
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
      String lid = sh.getString('lid').toString();
      String apiUrl = '$urls/examinerviewallocatedexam/';

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
          filteredUsers = tempList
              .where((user) =>
              user['examname']
                  .toString()
                  .toLowerCase()
                  .contains(searchValue.toLowerCase()))
              .toList();
          nameSuggestions = users.map((e) => e['examname'].toString()).toSet().toList();
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
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final user = filteredUsers[index];
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
                    SharedPreferences sh=await SharedPreferences.getInstance();
                    sh.setString('exam',user['id'].toString());
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>view_question(title: '',)));

                  }, child: Text('Question')),


                  ElevatedButton(onPressed: ()async{
                    SharedPreferences sh=await SharedPreferences.getInstance();
                    sh.setString('eid', user['exam'].toString());
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewExamRequest(title: '',)));


                  }, child: const Text("Exam Request")),


                  ElevatedButton(onPressed: ()async{
                    SharedPreferences sh=await SharedPreferences.getInstance();
                    sh.setString('eid', user['exam'].toString());
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>StaffViewMark(title: '',)));


                  }, child: const Text("Marks")),


                  ElevatedButton(onPressed: ()async{
                    SharedPreferences sh=await SharedPreferences.getInstance();
                    sh.setString('eid', user['exam'].toString());
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>viewproctoractivities(title: '',)));


                  }, child: const Text("Proctor Activities")),


                ],
              ),
            ),
          );
        },
      ),
    ));
  }
}
