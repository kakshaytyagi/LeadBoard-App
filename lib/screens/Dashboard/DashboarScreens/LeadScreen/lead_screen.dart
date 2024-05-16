import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leadboard_app/screens/Dashboard/DashboarScreens/LeadScreen/chat_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:leadboard_app/reusable_widgets/dummy.dart';

class DetailScreen extends StatefulWidget {
  final String name;
  final String imageUrl;

  const DetailScreen({
    required this.name,
    required this.imageUrl,
  });

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
  String userID = FirebaseAuth.instance.currentUser!.uid;
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userID)
      .collection('contacts')
      .doc(widget.name.toLowerCase())
      .collection('contactList')
      .get();

  List<Contact> fetchedContacts = [];

  for (var doc in querySnapshot.docs) {
    String phoneNumber = doc['contact'];
    List<Map<String, dynamic>> messages = await loadMessages(phoneNumber);

    messages.sort((a, b) => b['date'].compareTo(a['date']));

    String lastMessage = messages.isNotEmpty ? messages.first['text'] : '';

    Contact contact = Contact(
        name: doc['name'],
        phoneNumber: phoneNumber,
        lastMessage: lastMessage,
        status: doc['status']);

    fetchedContacts.add(contact);
  }

  // Sort contacts based on status: 1 first, 0 next, -1 last
  fetchedContacts.sort((a, b) => b.status.compareTo(a.status));

  setState(() {
    contacts = fetchedContacts;
  });
}

  Future<List<Map<String, dynamic>>> loadMessages(String phoneNumber) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    List<Map<String, dynamic>> messages = [];

    DocumentReference contactDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .collection('contacts')
        .doc(widget.name.toLowerCase())
        .collection('contactList')
        .doc(phoneNumber);

    try {
      DocumentSnapshot contactSnapshot = await contactDoc.get();

      if (contactSnapshot.exists) {
        dynamic? data = contactSnapshot.data();
        List<dynamic>? messagesData = data?['messages'];

        if (messagesData != null) {
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

  Future<void> markContactAsImportant(String phoneNumber) async {
    try {
      String userID = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('contacts')
          .doc(widget.name.toLowerCase())
          .collection('contactList')
          .doc(phoneNumber)
          .update({
        'important': true,
      });
    } catch (error) {
      print('Error marking contact as important: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(widget.imageUrl),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Text(
              widget.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            color: Colors.yellow,
            onPressed: () {
              // Add functionality for the light button
            },
          ),
        ],
      ),
      body: contacts.isEmpty
          ? Center(
              child: Image.asset(
                'assets/images/source.gif',
                width: 200,
                height: 200,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return GestureDetector(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Add to Important?"),
                          content: const Text(
                              "Do you want to add this contact to Important?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                await markContactAsImportant(
                                    contact.phoneNumber);
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: const Text('Contact added to Important'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: const Text("Add"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 249, 180, 222)
                              .withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 20,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            leading: const CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/images/profile.png'),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  contact.name.length > 20
                                      ? '${contact.name.substring(0, 20)}...'
                                      : contact.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.all(2),
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
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  contact.lastMessage.length > 60
                                      ? '${contact.lastMessage.substring(0, 60)}...'
                                      : contact.lastMessage,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        String phoneNumber =
                                            contact.phoneNumber;
                                        if (!await launch('tel:$phoneNumber')) {
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
                                      icon: const Icon(
                                        Icons.phone,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
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
                                        backgroundColor: const Color.fromARGB(
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
                                      label: const Text(
                                        'WhatsApp',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                              255, 6, 6, 6),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            tileColor: const Color.fromARGB(255, 246, 76, 133)
                                .withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            onTap: () async {
                              List<Map<String, dynamic>> messages =
                                  await loadMessages(contact.phoneNumber);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                      name: contact.name,
                                      phoneNumber: contact.phoneNumber,
                                      category: widget.name.toLowerCase(),
                                      messages: messages,
                                      status: contact.status),
                                ),
                              ).then((value) {
                                loadContacts();
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
