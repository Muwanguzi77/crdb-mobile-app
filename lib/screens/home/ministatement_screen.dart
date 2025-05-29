import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class MiniStatementScreen extends StatefulWidget {
  final String accountNumber = '21417434250032';

  @override
  _MiniStatementScreenState createState() => _MiniStatementScreenState();
}

class _MiniStatementScreenState extends State<MiniStatementScreen> {
  bool _loading = true;
  List<dynamic> _transactions = [];

  Future<void> _fetchMiniStatement() async {
    final url = Uri.parse("http://10.173.78.232:8080/ministatement");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "account_number": widget.accountNumber,
        }),
      );

      final List<dynamic> data = jsonDecode(response.body);

      data.sort((a, b) => b['transactionDateTime'].compareTo(a['transactionDateTime']));
      final latest6 = data.take(6).toList();

      setState(() {
        _transactions = latest6;
        _loading = false;
      });
    } catch (e) {
      print("Error fetching mini statement: $e");
      setState(() => _loading = false);
    }
  }

  String formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  @override
  void initState() {
    super.initState();
    _fetchMiniStatement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Last 6 Transactions"),
        backgroundColor: Colors.blue[800],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
          ? Center(child: Text("No transactions found."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final tx = _transactions[index];
          final isCredit = tx['transactionType'] == 'CREDIT';

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isCredit ? 'CREDIT' : 'DEBIT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCredit ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        formatDate(tx['transactionDateTime']),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "UGX ${tx['creditAmount'].toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("Narration: ${tx['transactionNarration']}"),
                  Text("Depositor: ${tx['depositorName']}"),
                  Text("Phone: ${tx['depositorPhoneNumber']}"),
                  Text("Ref: ${tx['externalTranRefNum']}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
