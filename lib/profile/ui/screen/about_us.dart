import 'package:flutter/material.dart';
import 'package:sanitary_mart/core/widget/custom_app_bar.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(
       title: 'About Us',
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ensures the content is center aligned vertically
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Our Company Ltd.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8), // Adds a small space between items
              Text(
                '123 Tech Avenue,\nInnovation City, 10101',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Mobile: +123 456 7890',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Email: contact@ourcompany.com',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}