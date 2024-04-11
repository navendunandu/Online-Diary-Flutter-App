import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_dairy/myprofile.dart';
import 'package:online_dairy/payment.dart';

class MyBookingsPage extends StatefulWidget {
  final String userId;

  const MyBookingsPage({required this.userId, Key? key}) : super(key: key);

  @override
  _MyBookingsPageState createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  Future<QuerySnapshot> fetchBookings() async {
    return await FirebaseFirestore.instance
        .collection('tbl_booking')
        .where('user_id', isEqualTo: widget.userId)
        .get();
  }

  String _getStatusText(String status) {
    if (status == '0') {
      return 'Pending';
    } else if (status == '1') {
      return 'Make Payment';
    } else if (status == '2') {
      return 'Rejected';
    } else if (status == '3') {
      return 'Paid';
    } else {
      return 'Error';
    }
  }

  Future<DocumentSnapshot> fetchProduct(String productId) async {
    return await FirebaseFirestore.instance
        .collection('tbl_product')
        .doc(productId)
        .get();
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
            icon: Icon(Icons.person), // Replace with the desired icon
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder(
          future: fetchBookings(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> bookingData =
                    snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                String productId = bookingData['product_id'];
                String bookingId = snapshot.data!.docs[index].id;

                return FutureBuilder(
                  future: fetchProduct(productId),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> productSnapshot) {
                    if (productSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (productSnapshot.hasError) {
                      return Text('Error: ${productSnapshot.error}');
                    }

                    Map<String, dynamic> productData =
                        productSnapshot.data!.data() as Map<String, dynamic>;

                    return Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey,
                      ),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product Name: ${productData['product_name']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Booking Date: ${bookingData['booking_date']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Product Rate: ${productData['product_rate']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          Image.network(
                            productData['product_photo'], // Assuming product_photo is a URL to the image
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 8),
                          Text(
                            _getStatusText(bookingData['status'].toString()),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          if (bookingData['status'] == 1) // Show payment button if status is 'make payment'
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentPage(id: bookingId),
                                  ),
                                );
                              },
                              child: Text('Make Payment'),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
