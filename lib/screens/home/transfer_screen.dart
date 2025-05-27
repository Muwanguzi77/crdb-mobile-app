import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home_screen.dart';

class TransferMoneyScreen extends StatefulWidget {
  @override
  _TransferMoneyScreenState createState() => _TransferMoneyScreenState();
}

class _TransferMoneyScreenState extends State<TransferMoneyScreen> {
  final TextEditingController _sourceAccountController = TextEditingController();
  final TextEditingController _destinationAccountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _narrationController = TextEditingController();

  bool _isLoading = false;

  Future<void> _transferMoney() async {
    final url = Uri.parse('http://10.0.2.2:8080/transfer');
    final body = jsonEncode({
      "src_acc_number": _sourceAccountController.text.trim(),
      "dest_acc_number": _destinationAccountController.text.trim(),
      "amount": int.parse(_amountController.text.trim()),
      "transaction_narration": _narrationController.text.trim(),
    });

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      setState(() => _isLoading = false);
      final responseData = jsonDecode(response.body);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Transfer Success'),
          content: Text(responseData['message']),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog first
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                );
              },
              child: Text('OK'),
            )
          ],
        ),
      );

      // if (response.statusCode == 201) {
      //   final responseData = jsonDecode(response.body);
      //   showDialog(
      //     context: context,
      //     builder: (_) => AlertDialog(
      //       title: Text('Success'),
      //       content: Text(responseData['message']),
      //       actions: [
      //         TextButton(
      //           onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
      //           child: Text('OK'),
      //         )
      //       ],
      //     ),
      //   );
      // } else {
      //   throw Exception('Failed to transfer money');
      // }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transfer to Another Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _sourceAccountController,
              decoration: InputDecoration(labelText: 'Source Account Number'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _destinationAccountController,
              decoration: InputDecoration(labelText: 'Destination Account Number'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _narrationController,
              decoration: InputDecoration(labelText: 'Transaction Narration'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _transferMoney,
                child: Text('Submit'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
