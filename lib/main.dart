import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(BelugangVerificationApp());
}

class BelugangVerificationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Belugang Verification',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          headlineMedium: TextStyle(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          labelStyle: TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      themeMode: ThemeMode.dark, // Set to dark mode
      home: MyHomePage(title: 'Belugang Verification'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _name;
  String? _username;
  Uint8List? _selectedImageBytes;

  void _discordServer() async {
    const url = 'https://discord.gg/belugang-2-1231948380285042688';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      _discordServer();
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      if (_selectedImageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please upload an image')),
        );
      } else {
        String webhookUrl =
            'https://discord.com/api/webhooks/1252893173370322944/iaCLkS2J1D3YBzTm5canlx_msqpihbutKZjU2mDUt8KwEtKAl8f0DXrZg4Vjli4FO94k';

        try {
          var request = http.MultipartRequest('POST', Uri.parse(webhookUrl));
          request.headers['Content-Type'] = 'multipart/form-data';

          // Add text fields
          request.fields['content'] = '''
            Form Submitted:
            Name or Nickname: $_name
            Discord Username: $_username
          ''';

          // Add image file
          request.files.add(http.MultipartFile.fromBytes(
            'file',
            _selectedImageBytes!,
            filename: 'image.jpg',
          ));

          var response = await request.send();

          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Form Submitted Successfully!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to submit form. Please try again later.'),
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit form. Please try again later.'),
            ),
          );
          print('Error sending webhook: $e');
        }
      }
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
    );

    if (result != null) {
      // Read file as bytes
      Uint8List bytes = result.files.single.bytes!;
      setState(() {
        _selectedImageBytes = bytes;
      });
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white54,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.discord),
            label: 'Discord Server',
          ),
        ],
      ),
      body: Center(
        child: GlassBox(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Name or Nickname',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name or nickname';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _name = value;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Discord Username',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Discord username';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _username = value;
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Upload an image of your Discord profile (Must include username, picture and etc)',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: Text('Upload Image File'),
                  ),
                  if (_selectedImageBytes != null) ...[
                    SizedBox(height: 16),
                    Image.memory(
                      _selectedImageBytes!,
                      height: 100,
                      width: 100,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                    ),
                  ],
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Submit'),
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

class GlassBox extends StatelessWidget {
  final Widget child;

  GlassBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

//