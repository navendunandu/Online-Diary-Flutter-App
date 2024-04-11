import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:online_dairy/feedback.dart';
import 'package:online_dairy/information.dart';
import 'package:online_dairy/login.dart';
import 'package:online_dairy/milkdetails.dart';
import 'package:online_dairy/mybooking.dart';
import 'package:online_dairy/mycomplaint.dart';
import 'package:online_dairy/myprofile.dart';
import 'package:online_dairy/pension.dart';
import 'package:online_dairy/postcomplaint.dart';
import 'package:online_dairy/stock.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    late String documentId;
    late String diaryId;

  @override
  void initState() {
    super.initState();
    fetchDocumentId();
  }

  Future<void> fetchDocumentId() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('tbl_user')
        .where('user_id', isEqualTo: userId)
        .get();

    setState(() {
      documentId = userSnapshot.docs.first.id;
      diaryId = userSnapshot.docs.first['diary_id'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Online Dairy'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyProfile()),
              );
            },
            icon: Icon(Icons.person), // Replace with the desired icon
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              height: 50,
            ),
            ListTile(
              title: const Text('My Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyProfile()),
                );
              },
            ),
            ListTile(
              title: const Text('My Booking'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyBookingsPage(userId: documentId,)),
                );
              },
            ),
            ListTile(
              title: const Text('Post Complaint'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ComplaintScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Feedback'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedbackScreen(uid: documentId,)),
                );
              },
            ),
            ListTile(
              title: const Text('My Complaints'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ComplaintsPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                _auth.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login(),));
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          height: 900,
          width: 900,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 118, 118, 118),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListView(
            children: [
              Image.asset("assets/milmalogo2.jpg"),
              const SizedBox(
                    height: 20,
                  ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                         onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => Milkdetails(userId: documentId,)),
                            );
                            },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey,
                            ),
                            height: 100,
                            width: 150,
                            padding: const EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                'Milk Details',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.normal,
                                  color: const Color.fromARGB(255, 244, 246, 246),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      GestureDetector(
                         onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => Pension(userId: documentId,)),
                            );
                            },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey,
                            ),
                            height: 100,
                            width: 150,
                            padding: const EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                'Pension',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.normal,
                                  color: const Color.fromARGB(255, 244, 246, 246),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                         onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => ProductPage(userid: documentId,diaryid: diaryId,)),
                            );
                            },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey,
                            ),
                            height: 100,
                            width: 150,
                            padding: const EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                'Stock',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.normal,
                                  color: const Color.fromARGB(255, 244, 246, 246),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      GestureDetector(
                         onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => const InformationPage()),
                            );
                            },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey,
                            ),
                            height: 100,
                            width: 150,
                            padding: const EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                'Information',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.normal,
                                  color: const Color.fromARGB(255, 244, 246, 246),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
