import 'dart:convert';

import 'package:ai_watcher/Staff/staff_home.dart';
import 'package:ai_watcher/Staff/viewallocatedexam.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// ─── Theme ────────────────────────────────────────────────────────────────────
const _primary      = Color(0xFF194569);
const _primaryLight = Color(0xFF2A6096);
const _bg           = Color(0xFFF0F4F8);
const _card         = Colors.white;
const _text         = Color(0xFF0D1F2D);
const _sub          = Color(0xFF607D8B);
const _divider      = Color(0xFFE8EEF4);
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  runApp(const ViewHouseApp());
}

class ViewHouseApp extends StatelessWidget {
  const ViewHouseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: viewpayment(title: 'View Users'),
    );
  }
}

class viewpayment extends StatefulWidget {
  const viewpayment({super.key, required this.title});
  final String title;

  @override
  State<viewpayment> createState() => _viewpaymentState();
}

class _viewpaymentState extends State<viewpayment> {
  List<Map<String, dynamic>> users         = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<String> nameSuggestions             = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    viewUsers("");
  }

  Future<void> viewUsers(String searchValue) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String eid  = sh.getString('lid') ?? '';
      String apiUrl = '$urls/viewpaymwnt_staff/';

      var response = await http.post(Uri.parse(apiUrl), body: {'eid': eid});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'id':     item['id'],
            'date':   item['date'],
            'amount': item['amount'],
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

  // ── Total amount ──────────────────────────────────────────────────────────
  double get _totalAmount {
    return filteredUsers.fold(0.0, (sum, item) {
      return sum + (double.tryParse(item['amount'].toString()) ?? 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (context) => const viewallocatedexam(title: '')));
        return false;
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [

            // ── Gradient Header ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primary, _primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -30, right: -20,
                    child: Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8, right: 35,
                    child: Container(
                      width: 55, height: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Back + title row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                    const StaffHome())),
                            child: Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.2)),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Payments',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)),
                                Text('View payment history',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white60)),
                              ],
                            ),
                          ),
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2)),
                            ),
                            child: const Icon(Icons.account_balance_wallet_outlined,
                                color: Colors.white, size: 20),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // ── Search bar ─────────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          onChanged: (value) {
                            setState(() {
                              filteredUsers = users
                                  .where((u) => u['date']
                                  .toString()
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                                  .toList();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search by date...',
                            hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 13),
                            prefixIcon: Icon(Icons.search,
                                color: Colors.white.withOpacity(0.7),
                                size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Count + total row ──────────────────────────
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.13),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.receipt_outlined,
                                    color: Colors.white70, size: 15),
                                const SizedBox(width: 6),
                                Text(
                                  '${filteredUsers.length} record${filteredUsers.length == 1 ? '' : 's'}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.13),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.currency_rupee,
                                    color: Colors.white70, size: 15),
                                const SizedBox(width: 4),
                                Text(
                                  'Total: ${_totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── List ──────────────────────────────────────────────────
            Expanded(
              child: filteredUsers.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_balance_wallet_outlined,
                        size: 64, color: _sub.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text('No payments found',
                        style: TextStyle(
                            fontSize: 15,
                            color: _sub.withOpacity(0.6),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _divider),
                      boxShadow: [
                        BoxShadow(
                          color: _primary.withOpacity(0.07),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ── Top row: icon + date + index badge ──
                          Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [_primary, _primaryLight],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Text('Payment Record',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: _text)),
                                    Text(
                                      user['date'].toString(),
                                      style: const TextStyle(
                                          fontSize: 11, color: _sub),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _primary.withOpacity(0.07),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('#${index + 1}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: _primary)),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),
                          Divider(color: _divider, height: 1),
                          const SizedBox(height: 12),

                          // ── Amount highlight row ─────────────
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _primary.withOpacity(0.06),
                                  _primaryLight.withOpacity(0.03),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: _primary.withOpacity(0.12)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(
                                    color: _primary.withOpacity(0.1),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                      Icons.currency_rupee,
                                      color: _primary, size: 15),
                                ),
                                const SizedBox(width: 10),
                                const Text('Amount',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _sub)),
                                const Spacer(),
                                Text(
                                  '₹ ${user['amount']}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: _primary),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // ── Status badge ─────────────────────
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.08),
                                  borderRadius:
                                  BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.green
                                          .withOpacity(0.25)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                        Icons.check_circle_outline_rounded,
                                        color:
                                        Colors.green.withOpacity(0.8),
                                        size: 13),
                                    const SizedBox(width: 5),
                                    Text('Payment Received',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green
                                                .withOpacity(0.8))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}