import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_dairy/myprofile.dart';

class Milkdetails extends StatefulWidget {
  final String userId;

  const Milkdetails({required this.userId, super.key});

  @override
  State<Milkdetails> createState() => _MilkdetailsState();
}

class _MilkdetailsState extends State<Milkdetails> {
  
  Future<QuerySnapshot> fetchMilkDetails(String userId) async {
    return await FirebaseFirestore.instance.collection('tbl_milk').where('user_id', isEqualTo: userId).get();
  }

  String _getStatusText(String status) {
    if (status == '0') {
      return 'Not Payed';
    } else if (status == '1') {
      return 'Payed';
    } else {
      return 'Unknown';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyProfile()),
              );
            },
            icon: Icon(Icons.person),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder(
          future: fetchMilkDetails(widget.userId),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data = snapshot.data?.docs[index].data() as Map<String, dynamic>;
                return Container(
                  margin: EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey,
                  ),
                  width: 400,
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date: ${data['milk_date']}',
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.normal,
                          color: const Color.fromARGB(255, 244, 246, 246),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        'Quantity: ${data['milk_quantity']}',
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.normal,
                          color: const Color.fromARGB(255, 244, 246, 246),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        'Quality: ${data['milk_quality']}',
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.normal,
                          color: const Color.fromARGB(255, 244, 246, 246),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Row(
                        children: [
                          Text('Status:'),
                          Text(_getStatusText(data['status'].toString()))
                        ],
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
