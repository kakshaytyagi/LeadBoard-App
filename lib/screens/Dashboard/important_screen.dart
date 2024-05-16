import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leadboard_app/reusable_widgets/dummy.dart';
import 'package:leadboard_app/screens/Dashboard/DashboarScreens/LeadScreen/chat_screen.dart';

class ImportantPage extends StatefulWidget {
  @override
  _ImportantPageState createState() => _ImportantPageState();
}

class _ImportantPageState extends State<ImportantPage> {
  List<ImpContact> contacts = [];
  bool isLoading = true; // Add isLoading flag to track data loading state

  @override
  void initState() {
    super.initState();
    loadImportantContacts();
  }

  Future<void> loadImportantContacts() async {
    // Query Firestore to fetch all contacts where important = true
    String userID = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Fetch contacts where important = true
      QuerySnapshot contactsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('contacts')
          .get();

      // Clear existing contacts list
      setState(() {
        contacts.clear();
      });

      for (QueryDocumentSnapshot contactDoc in contactsSnapshot.docs) {
        QuerySnapshot contactListSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .collection('contacts')
            .doc(contactDoc.id)
            .collection('contactList')
            .get();

        for (QueryDocumentSnapshot detailDoc in contactListSnapshot.docs) {
          var detailData = detailDoc.data();
          bool important = detailDoc['important'];
          if (important) {
            String phoneNumber = detailDoc['contact'];

            List<Map<String, dynamic>> messages =
                await loadMessages(phoneNumber, contactDoc.id);

            messages.sort((a, b) => b['date'].compareTo(a['date']));

            String lastMessage =
                messages.isNotEmpty ? messages.first['text'] : '';
            setState(() {
              contacts.add(ImpContact(
                name: detailDoc['name'],
                phoneNumber: phoneNumber,
                lastMessage: lastMessage,
                status: detailDoc['status'],
                category: contactDoc.id,
              ));
            });
          }
        }
      }
      setState(() {
        isLoading =
            false; // Set isLoading to false when data loading is complete
      });
    } catch (error) {
      setState(() {
        isLoading = false; // Set isLoading to false in case of error
      });
    }
  }

  Future<List<Map<String, dynamic>>> loadMessages(
      String phoneNumber, String category) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    List<Map<String, dynamic>> messages = [];

    DocumentReference contactDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .collection('contacts')
        .doc(category.toLowerCase())
        .collection('contactList')
        .doc(phoneNumber);

    try {
      DocumentSnapshot contactSnapshot = await contactDoc.get();

      if (contactSnapshot.exists) {
        dynamic? data = contactSnapshot.data();
        List<dynamic>? messagesData = data?['messages'];

        if (messagesData != null && messagesData is List<dynamic>) {
          messages = messagesData.map((message) {
            return {
              'sender': "customer",
              'text': message['content'],
              'date': message['timestamp'].toDate(),
            };
          }).toList();
        } else {}
      } else {}
    } catch (error) {}

    return messages;
  }

  Future<void> markContactAsUnImportant(
      String phoneNumber, String category) async {
    try {
      String userID = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('contacts')
          .doc(category.toLowerCase())
          .collection('contactList')
          .doc(phoneNumber)
          .update({
        'important': false,
      });
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage("assets/images/important.png"),
              radius: 20,
            ),
            SizedBox(width: 10),
            Text(
              "Important",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.blue, // Change app bar color
        elevation: 0, // Remove app bar elevation
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator(), // Show loading indicator while data is being fetched
            )
          : contacts.isEmpty
              ? Center(
                  child: Image.asset(
                    'assets/images/source.gif', // Path to your GIF asset
                    width: 200,
                    height: 200,
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Remove from Important?"),
                              content: Text(
                                  "Do you want to remove this contact from Important?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await markContactAsUnImportant(
                                        contact.phoneNumber, contact.category);
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Contact remove sucessfully'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    loadImportantContacts();
                                  },
                                  child: Text("Remove"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(255, 249, 180, 222)
                                  .withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 20,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                leading: CircleAvatar(
                                  backgroundImage:
                                      AssetImage('assets/images/profile.png'),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      contact.name.length > 20
                                          ? '${contact.name.substring(0, 20)}...'
                                          : contact.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Spacer(),
                                    Container(
                                      padding: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: contact.status == -1
                                              ? Colors.red
                                              : contact.status == 0
                                                  ? Colors.yellow
                                                  : Colors.green,
                                          width: 2,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 9,
                                        backgroundColor: contact.status == -1
                                            ? Colors.red
                                            : contact.status == 0
                                                ? Colors.yellow
                                                : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      contact.phoneNumber,
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      contact.lastMessage.length > 60
                                          ? '${contact.lastMessage.substring(0, 60)}...'
                                          : contact.lastMessage,
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            String phoneNumber =
                                                contact.phoneNumber;
                                            if (!await launch(
                                                'tel:$phoneNumber')) {
                                              throw 'Could not launch';
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          icon: Icon(
                                            Icons.phone,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            'Call',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            String phoneNumber =
                                                contact.phoneNumber;
                                            final url =
                                                'whatsapp://send?phone=$phoneNumber';
                                            if (!await launch(url)) {
                                              throw 'Could not launch';
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 229, 232, 229),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          icon: Image.asset(
                                            'assets/images/whatsapp.png',
                                            width: 28,
                                            height: 28,
                                            fit: BoxFit.contain,
                                          ),
                                          label: Text(
                                            'WhatsApp',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromARGB(
                                                  255, 6, 6, 6),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                tileColor:
                                    const Color.fromARGB(255, 246, 76, 133)
                                        .withOpacity(0.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                onTap: () async {
                                  List<Map<String, dynamic>> messages =
                                      await loadMessages(contact.phoneNumber,
                                          contact.category);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                          name: contact.name,
                                          phoneNumber: contact.phoneNumber,
                                          category: contact.category,
                                          messages: messages,
                                          status: contact.status),
                                    ),
                                  ).then((value) {
                                    loadImportantContacts();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
