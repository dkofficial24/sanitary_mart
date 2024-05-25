import 'package:flutter/material.dart';
import 'package:sanitary_mart/core/widget/custom_app_bar.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'About Us',
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Ensures the content is center aligned vertically
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Icon(
                        Icons.store,
                        color: Colors.blueAccent,
                        size: 40,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Shree Balaji Sanitary & Electronics',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.blueAccent,
                    thickness: 1.5,
                  ),
                  SizedBox(height: 8), // Adds a small space between items
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.blueAccent,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bhiwani Road, Bahal',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        color: Colors.blueAccent,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Phone: 9555294879',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        color: Colors.blueAccent,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Email: narendra.kharsu@gmail.com',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
