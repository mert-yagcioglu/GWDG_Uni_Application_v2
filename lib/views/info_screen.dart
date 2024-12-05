import 'package:flutter/material.dart';
import 'dart:io';

class InfoScreen extends StatelessWidget {
  final File imageFile;
  final String? fdoId;

  InfoScreen({required this.imageFile, this.fdoId, required color, required size});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FDO Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: Image.file(
                imageFile,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Color',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Color',
              ),
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: 20),
            Text(
              'Size',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Size',
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
