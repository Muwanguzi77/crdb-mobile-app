import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MiniStatementScreen extends StatefulWidget {
  // final String token;
  final String accountNumber = '21417434250032';

  // MiniStatementScreen({required this.token, required this.accountNumber});

  @override
  _MiniStatementScreenState createState() => _MiniStatementScreenState();
}

class _MiniStatementScreenState extends State<MiniStatementScreen> {
  bool _loading = true;
  List<dynamic> _transactions = [];

  Future<void> _fetchMiniStatement() async {
    final url = Uri.parse("http://10.0.2.2:8080/ministatement");
    final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "account_number": "21417434250032",
        })
    );
    print("Raw Response Body: ${response.body}"); // 🔍 This logs the raw response

    final List<dynamic> data = jsonDecode(response.body); // response is a list

    setState(() {
      _transactions = data;
      _loading = false;
    });
    // final data = jsonDecode(response.body);
    // setState(() {
    //   _transactions = data['transactions'] ?? [];
    //   _loading = false;
    // });
    // if (response.statusCode != 200) { //success scenario
    //   final data = jsonDecode(response.body);
    //   setState(() {
    //     _transactions = data['transactions'] ?? [];
    //     _loading = false;
    //   });
    // } else {
    //   setState(() => _loading = false);
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Failed to fetch mini statement')),
    //   );
    // }
  }

  @override
  void initState() {
    super.initState();
    _fetchMiniStatement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mini Statement")),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final tx = _transactions[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(
                "Amount: UGX ${tx['creditAmount']}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Date: ${DateTime.fromMillisecondsSinceEpoch(tx['transactionDateTime']).toString()}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text("Type: ${tx['transactionType']}"),
                  Text("Depositor Name: ${tx['depositorName']}"),
                  Text("Narration: ${tx['transactionNarration']}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
// TODO Implement this library.