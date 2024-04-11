import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:online_dairy/login.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => RegistrationState();
}

class RegistrationState extends State<Registration> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  XFile? _selectedImage;
  String? _imageUrl;

  String selectedDistrict = '';
  String selectedPlace = '';
  String selectedDiary = '';

  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> places = [];
  List<Map<String, dynamic>> diary = [];

  late ProgressDialog _progressDialog;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _progressDialog = ProgressDialog(context);
    fetchDistricts();
  }

  Future<void> fetchDistricts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('tbl_district').get();

      List<Map<String, dynamic>> tempDistricts = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['district_name'].toString(),
              })
          .toList();

      setState(() {
        districts = tempDistricts;
      });
      print(tempDistricts);
    } catch (e) {
      print('Error fetching district data: $e');
    }
  }

  Future<void> fetchPlaceData(id) async {
    places = [];
    diary = [];
    try {
      // Replace 'tbl_course' with your actual collection name
      QuerySnapshot<Map<String, dynamic>> querySnapshot1 =
          await FirebaseFirestore.instance
              .collection('tbl_place')
              .where('district_id', isEqualTo: id)
              .get();

      List<Map<String, dynamic>> place = querySnapshot1.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['place_name'].toString(),
              })
          .toList();

      setState(() {
        places = place;
      });
      print(place);
    } catch (e) {
      print('Error fetching place data: $e');
    }
  }

  Future<void> fetchDiaryData(id) async {
    print(id);
    diary = [];
    try {
      // Replace 'tbl_course' with your actual collection name
      QuerySnapshot<Map<String, dynamic>> querySnapshot1 =
          await FirebaseFirestore.instance
              .collection('tbl_diary')
              .where('place_id', isEqualTo: id)
              .get();

      List<Map<String, dynamic>> diaries = querySnapshot1.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['diary_name'].toString(),
              })
          .toList();

      setState(() {
        diary = diaries;
      });
    } catch (e) {
      print('Error fetching place data: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = XFile(pickedFile.path);
      });
    }
  }

  Future<void> register() async {
    if (_formKey.currentState!.validate()) {
      try {
        _progressDialog.show();
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (userCredential != null) {
          await _storeUserData(userCredential.user!.uid);
          Fluttertoast.showToast(
            msg: "Registration Successful",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          _progressDialog.hide();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
        }
      } catch (e) {
        _progressDialog.hide();
        Fluttertoast.showToast(
          msg: "Registration Failed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        print("Error registering user: $e");
      }
    }
  }

  Future<void> _storeUserData(String userId) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('tbl_user').add({
        'user_name': _nameController.text,
        'user_email': _emailController.text,
        'user_contact': _contactController.text,
        'user_address': _addressController.text,
        'user_password': _passwordController.text,
        'user_id': userId,
        'place_id': selectedPlace,
        'user_doj': '',
        'diary_id': '',
        'user_status': 0,
      });

      await _uploadImage(userId);
    } catch (e) {
      print("Error storing user data: $e");
      // Handle error, show message or take appropriate action
    }
  }

  Future<void> _uploadImage(String userId) async {
    try {
      if (_selectedImage != null) {
        Reference ref =
            FirebaseStorage.instance.ref().child('User_photo/$userId.jpg');
        UploadTask uploadTask = ref.putFile(File(_selectedImage!.path));
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

        String imageUrl = await taskSnapshot.ref.getDownloadURL();
        Map<String, dynamic> newData = {
          'user_photo': imageUrl,
        };
        await FirebaseFirestore.instance
            .collection('tbl_user')
            .where('user_id', isEqualTo: userId) // Filtering by user_id
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            // For each document matching the query, update the data
            doc.reference.update(newData);
          });
        }).catchError((error) {
          print("Error updating user: $error");
        });
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xff4c505b),
                      backgroundImage: _selectedImage != null
                          ? FileImage(File(_selectedImage!.path))
                          : _imageUrl != null
                              ? NetworkImage(_imageUrl!)
                              : const AssetImage('assets/dummy-profile.png')
                                  as ImageProvider,
                      child: _selectedImage == null && _imageUrl == null
                          ? const Icon(
                              Icons.add,
                              size: 40,
                              color: Color.fromARGB(255, 41, 39, 39),
                            )
                          : null,
                    ),
                    if (_selectedImage != null || _imageUrl != null)
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 18,
                          child: Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text('User Registration'),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(hintText: 'Enter Name'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(hintText: 'Enter Email'),
            ),
            TextFormField(
              controller: _contactController,
              decoration: InputDecoration(hintText: 'Enter Contact'),
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(hintText: 'Enter Address'),
            ),
            DropdownButtonFormField<String>(
              value: selectedDistrict.isNotEmpty ? selectedDistrict : null,
              decoration: InputDecoration(
                hintText: 'District',
              ),
              onChanged: (String? newValue) {
                fetchPlaceData(newValue);
                setState(() {
                  selectedDistrict = newValue!;
                });
              },
              isExpanded: true,
              items: districts.map<DropdownMenuItem<String>>(
                (Map<String, dynamic> district) {
                  return DropdownMenuItem<String>(
                    value: district['id'],
                    child: Text(district['name']),
                  );
                },
              ).toList(),
              validator: (value) {
                if (value == null) {
                  return 'Please select a district';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Place',
              ),
              value: selectedPlace.isNotEmpty ? selectedPlace : null,
              onChanged: (String? newValue) {
                print('Selected value: $newValue');
                fetchDiaryData(newValue);
                setState(() {
                  selectedPlace = newValue!;
                });
              },
              isExpanded: true,
              items: places.map<DropdownMenuItem<String>>(
                (Map<String, dynamic> place) {
                  return DropdownMenuItem<String>(
                    value: place['id'].toString() ??
                        '', // Ensure id is converted to String
                    child: Text(place['name'] ?? ''), // Handle null name
                  );
                },
              ).toList(),
              validator: (value) {
                if (value == null) {
                  return 'Please select a place';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Diary',
              ),
              value: selectedDiary.isNotEmpty ? selectedDiary : null,
              onChanged: (String? newValue) {
                setState(() {
                  selectedDiary = newValue!;
                });
              },
              isExpanded: true,
              items: diary.map<DropdownMenuItem<String>>(
                (Map<String, dynamic> d) {
                  return DropdownMenuItem<String>(
                    value: d['id'],
                    child: Text(d['name']),
                  );
                },
              ).toList(),
              validator: (value) {
                if (value == null) {
                  return 'Please select a place';
                }
                return null;
              },
            ),
            TextFormField(
              obscureText: true,
              controller: _passwordController,
              decoration: InputDecoration(hintText: 'Enter Password'),
            ),
            ElevatedButton(
                onPressed: () {
                  register();
                },
                child: Text('Register'))
          ],
        ),
      ),
    );
  }
}
