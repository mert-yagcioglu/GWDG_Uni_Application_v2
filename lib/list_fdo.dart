import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'info_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class ListFDOScreen extends StatefulWidget {
  @override
  _ListFDOScreenState createState() => _ListFDOScreenState();
}

class _ListFDOScreenState extends State<ListFDOScreen> {
  late Database _database;
  List<Map<String, dynamic>> _fdoItems = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'fdo_database.db');
    _database = await openDatabase(path);
    _loadFDOItems();
  }

  Future<void> _loadFDOItems() async {
    final List<Map<String, dynamic>> items = await _database.query('fdo');
    setState(() {
      _fdoItems = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FDO List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CameraScreen()),
              );
            },
          ),
        ],
      ),
      body: _fdoItems.isEmpty
          ? Center(child: Text('No FDO items available'))
          : ListView.builder(
        itemCount: _fdoItems.length,
        itemBuilder: (context, index) {
          final fdoItem = _fdoItems[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
            child: Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                leading: Image.file(
                  File(fdoItem['imagePath']),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(
                  fdoItem['id'].toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Color: ${fdoItem['color']}'),
                    Text('Size: ${fdoItem['size']}'),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InfoScreen(
                          imageFile: File(fdoItem['imagePath']),
                          color: fdoItem['color'],
                          size: fdoItem['size'], fdoId: '',
                        ),
                      ),
                    );
                  },
                  child: Text('INFO'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
