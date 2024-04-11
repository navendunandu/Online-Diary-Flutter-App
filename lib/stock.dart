import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_dairy/mybooking.dart';
import 'package:online_dairy/myprofile.dart';
import 'package:intl/intl.dart';

class ProductPage extends StatefulWidget {
  final String userid;
  final String diaryid;
  const ProductPage({Key? key, required this.userid, required this.diaryid}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  
  Future<QuerySnapshot> fetchProducts() async {
  return await FirebaseFirestore.instance
      .collection('tbl_product')
      .where('diary_id', isEqualTo: widget.diaryid) // Add where condition here
      .get();
}

  Future<void> bookProduct(String? productId) async {
  if (productId != null) {
    try {
      // Get the current date and time
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      // Insert a new document into tbl_booking
      await FirebaseFirestore.instance.collection('tbl_booking').add({
        'product_id': productId,
        'booking_date': formattedDate,
        'status':0,
        'user_id':widget.userid
        // Add any additional fields you want to include in the booking document
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product booked successfully!')),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyBookingsPage(userId: widget.userid),));
    } catch (e) {
      print('Error booking product: $e');
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking product. Please try again later.')),
      );
    }
  } else {
    print('Error: Product ID is null');
    // Show an error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: Product ID is null')),
    );
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
            icon: Icon(Icons.person), // Replace with the desired icon
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder(
          future: fetchProducts(),
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
                Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                String productId = snapshot.data!.docs[index].id;
                print('product:$productId');
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
                        'Name: ${data['product_name']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Description: ${data['product_des']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Rate: ${data['product_rate']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Image.network(
                        data['product_photo'], // Assuming product_photo is a URL to the image
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          bookProduct(productId);
                        },
                        child: Text('Book Now'),
                      ),
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
