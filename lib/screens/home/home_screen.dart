import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'deposit_screen.dart';
import 'transfer_screen.dart';
import 'ministatement_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String accountNumber = '';
  double accountBalance = 0.0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccountDetails();
  }

  Future<void> _fetchAccountDetails() async {
    final url = Uri.parse("http://10.0.2.2:8080/accountDetails");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "account_number": "21417434250032",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          accountNumber = data['accountNumber'].toString();
          accountBalance = data['balance']?.toDouble() ?? 0.0;
          loading = false;
        });
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load account details')),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while fetching account details')),
      );
    }
  }

  Widget _buildTile(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSummaryCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 100.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Account Number",
                style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            SizedBox(height: 4),
            Text(accountNumber,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text("Balance",
                style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            SizedBox(height: 4),
            Text("UGX ${accountBalance.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[700])),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildAccountSummaryCard(),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildTile("Transfer", Icons.swap_horiz, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransferMoneyScreen(),
                      ),
                    );
                  }),
                  _buildTile("Mini Statement", Icons.receipt_long, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MiniStatementScreen(),
                      ),
                    );
                  }),
                  _buildTile("Deposit", Icons.account_balance_wallet, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DepositMoneyScreen(),
                      ),
                    );
                  }),
                  _buildTile("Send Money", Icons.send, () {}),
                  _buildTile("School Fees", Icons.school, () {}),
                  _buildTile("Loans", Icons.money, () {}),
                  _buildTile("Settings", Icons.settings, () {}),
                  _buildTile("Transactions", Icons.history, () {}),
                  _buildTile("Cente Xpress", Icons.flash_on, () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
