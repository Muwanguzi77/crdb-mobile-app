import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TaxpayerProfileScreen extends StatefulWidget {
  @override
  _TaxpayerProfileScreenState createState() => _TaxpayerProfileScreenState();
}

class _TaxpayerProfileScreenState extends State<TaxpayerProfileScreen> {
  final _taxpayerIdController = TextEditingController();
  String _selectedTaxpayerType = 'Individual';

  // Variables to hold API response
  String tin = '';
  String taxpayerName = '';
  String regDate = '';
  String status = '';

  bool isLoading = false;
  bool hasError = false;

  Future<void> _fetchTaxpayerInfo() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    String taxpayerId = _taxpayerIdController.text.trim();
    String taxpayerType = _selectedTaxpayerType.toLowerCase();

    // Set the request headers
    Map<String, String> headers = {
      'tin': taxpayerId,
      'type': taxpayerType,
    };

    try {
      // Make the API request
      final response = await http.get(
        Uri.parse('https://rl6wm.wiremockapi.cloud/tin_details/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          tin = data['TIN'];
          taxpayerName = data['Taxpayer_Name'];
          regDate = data['Reg_Date'];
          status = data['Status'];
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Taxpayer Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search By: \n TIN No, Email, NIN, Phone No,or '
                  'Business Registration No used in the registration of your TIN',
              //style: TextStyle(color: Colors.red),
            ),
            TextField(
              controller: _taxpayerIdController,
              decoration: InputDecoration(labelText: 'Taxpayer ID'),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedTaxpayerType,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTaxpayerType = newValue!;
                });
              },
              items: <String>['Individual', 'Non-individual']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchTaxpayerInfo,
              style: ElevatedButton.styleFrom(
                primary: Colors.yellow, // Button background color
                onPrimary: Colors.blue, // Button text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Proceed'),
            ),
            SizedBox(height: 20),
            // Show a loading indicator while fetching data
            if (isLoading) Center(child: CircularProgressIndicator()),
            // Show error message if something goes wrong
            if (hasError)
              Text(
                'Error fetching data. Please try again.',
                style: TextStyle(color: Colors.red),
              ),
            // Show the fetched data
            if (!isLoading && !hasError && tin.isNotEmpty)
              _buildTinDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildTinDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Use a styled container to hold the TIN details
        Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Tin Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Icon(Icons.info_outline, color: Colors.grey),
                ],
              ),
              SizedBox(height: 10),
              _buildDetailRow('Taxpayer Tin', tin),
              _buildDetailRow('Taxpayer Name', taxpayerName),
              _buildDetailRow('Registration Effective Date', regDate),
              _buildDetailRow('Status', status),
            ],
          ),
        ),
        SizedBox(height: 20),
        // Yellow button with blue text
        ElevatedButton(
          onPressed: null,
          // onPressed: () {
          //   // Implement the Registered Taxes button functionality
          // },
          style: ElevatedButton.styleFrom(
            primary: Colors.yellow, // Button background color
            onPrimary: Colors.blue, // Button text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text('Registered Taxes'),
        ),
      ],
    );
  }

  // Helper widget to build detail rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            label + ": ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
