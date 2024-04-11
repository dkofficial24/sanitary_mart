import 'package:flutter/material.dart';

class EditPersonalInformationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Personal Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                // Add more decoration properties as needed
              ),
              initialValue:
                  'John Doe', // Ideally, load this from a user model or similar
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                // Add more decoration properties as needed
              ),
              initialValue:
                  '+1234567890', // Ideally, load this from a user model or similar
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email',
                // Add more decoration properties as needed
              ),
              initialValue:
                  'johndoe@example.com', // Ideally, load this from a user model or similar
            ),
            ElevatedButton(
              onPressed: () {
                // Add save functionality here
                Navigator.pop(
                    context); // Go back to the previous screen after saving
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
