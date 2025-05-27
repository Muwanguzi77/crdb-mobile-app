import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../home/home_screen.dart';

class DepositMoneyScreen extends StatefulWidget {
  // final String token;
  // final String accountNumber;

  // DepositMoneyScreen({required this.token, required this.accountNumber});

  @override
  _DepositMoneyScreenState createState() => _DepositMoneyScreenState();
}

class _DepositMoneyScreenState extends State<DepositMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _depositorNameController = TextEditingController();
  final TextEditingController _depositorPhoneController = TextEditingController();
  final TextEditingController _narrationController = TextEditingController();

  bool _loading = false;

  Future<void> _depositMoney() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      final url = Uri.parse("http://10.0.2.2:8080/deposit");

      final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "account_number": _accountController.text,
            "amount": double.parse(_amountController.text),
            "depositor_name": _depositorNameController.text,
            "depositor_phone": _depositorPhoneController.text,
            "transaction_narration": _narrationController.text
          })
      );

      setState(() => _loading = false);
      // final Map<String, dynamic> data = jsonDecode(response.body);
      final data = jsonDecode(response.body);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Deposit Successful"),
          content: Text(data['message']),
          actions: [
            TextButton(
              child: Text("OK"),
              // onPressed: () => Navigator.pushReplacement(
              //     context,
              //     MaterialPageRoute(builder: (_) => HomeScreen())
              // ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog first
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                );
              },
            )
          ],
        ),
      );
      // if (response.statusCode == 201) {
      //   final Map<String, dynamic> data = jsonDecode(response.body);
      //   showDialog(
      //     context: context,
      //     builder: (_) => AlertDialog(
      //       title: Text("Deposit Successful"),
      //       content: Text(data['message']),
      //       actions: [
      //         TextButton(
      //           child: Text("OK"),
      //           onPressed: () => Navigator.pushReplacement(
      //               context,
      //               MaterialPageRoute(builder: (_) => HomeScreen())
      //           ),
      //         )
      //       ],
      //     ),
      //   );
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("Deposit failed. Try again.")),
      //   );
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Deposit Money")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _accountController,
                decoration: InputDecoration(labelText: "To Account"),
                validator: (value) => value!.isEmpty ? "Enter Account" : null,
              ),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Amount"),
                validator: (value) => value!.isEmpty ? "Enter amount" : null,
              ),
              TextFormField(
                controller: _depositorNameController,
                decoration: InputDecoration(labelText: "Depositor Name"),
                validator: (value) => value!.isEmpty ? "Enter depositor name" : null,
              ),
              TextFormField(
                controller: _depositorPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "Depositor Phone"),
                validator: (value) => value!.isEmpty ? "Enter phone number" : null,
              ),
              TextFormField(
                controller: _narrationController,
                decoration: InputDecoration(labelText: "Narration"),
                validator: (value) => value!.isEmpty ? "Enter narration" : null,
              ),
              SizedBox(height: 20),
              _loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                  onPressed: _depositMoney,
                  child: Text("Deposit")
              )
            ],
          ),
        ),
      ),
    );
  }
}
