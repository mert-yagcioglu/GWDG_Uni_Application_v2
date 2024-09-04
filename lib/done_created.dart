import 'package:flutter/material.dart';
import 'dart:io';

class DoneCreatedScreen extends StatelessWidget {
  final File imageFile;
  final String fdoId;

  DoneCreatedScreen({required this.imageFile, required this.fdoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Done'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 250,
              width: 250,
              child: Image.file(
                imageFile,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 30),
            Text(
              'New FDO Created',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'FDO ID: $fdoId',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
