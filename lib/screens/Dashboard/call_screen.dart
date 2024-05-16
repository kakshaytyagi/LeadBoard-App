import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:intl/intl.dart';
import 'package:leadboard_app/screens/Dashboard/CallScreens/add_contact.dart';
import 'package:leadboard_app/screens/Dashboard/CallScreens/contacts_screen.dart';

class CallsPage extends StatelessWidget {
  List<String> names = [
    "Commercial",
    "Industrial",
    "Residential",
    "Rental",
    "Others"
  ];
  String selectedCategory = "Commercial"; // Set default category

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recents',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false, // Disable back button
        actions: [
          IconButton(
            icon: Icon(
              Icons.contacts,
              color: Colors.white, // Set icon color to white
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactsPage()),
              );
              // Open contacts screen
            },
          ),
        ],
      ),
      body: FutureBuilder<Iterable<CallLogEntry>>(
        future: CallLog.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Preprocess call log entries to group them by date
            Map<String, List<CallLogEntry>> groupedCalls = {};
            snapshot.data!.forEach((entry) {
              DateTime timestamp =
                  DateTime.fromMillisecondsSinceEpoch(entry.timestamp!);
              String formattedDate = DateFormat.yMMMd().format(timestamp);
              groupedCalls.putIfAbsent(formattedDate, () => []).add(entry);
            });

            return ListView.builder(
              itemCount: groupedCalls.length,
              itemBuilder: (context, index) {
                String date = groupedCalls.keys.elementAt(index);
                List<CallLogEntry> calls = groupedCalls[date] ?? [];

                // Determine if the date is today or yesterday
                String heading = '';
                if (date == DateFormat.yMMMd().format(DateTime.now())) {
                  heading = 'Today';
                } else if (date ==
                    DateFormat.yMMMd()
                        .format(DateTime.now().subtract(Duration(days: 1)))) {
                  heading = 'Yesterday';
                } else {
                  heading = date;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Text(
                        heading,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: calls.length,
                      itemBuilder: (context, index) {
                        CallLogEntry call = calls[index];
                        IconData callIcon;
                        Color callIconColor;
                        switch (call.callType) {
                          case CallType.incoming:
                            callIcon = Icons.call_received;
                            callIconColor = Colors.green;
                            break;
                          case CallType.outgoing:
                            callIcon = Icons.call_made;
                            callIconColor = Colors.blue;
                            break;
                          case CallType.missed:
                            callIcon = Icons.call_missed;
                            callIconColor = Colors.red;
                            break;
                          default:
                            callIcon = Icons.call;
                            callIconColor = Colors.grey;
                        }

                        return ListTile(
                          leading: CircleAvatar(
                            child: Icon(callIcon, color: callIconColor),
                            backgroundColor: Colors.grey[300],
                          ),
                          title: Text(call.number ?? 'Unknown'),
                          subtitle: Text(
                            DateFormat.yMMMd().add_jm().format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    call.timestamp!)),
                          ),
                          trailing: Icon(Icons.add),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: SingleChildScrollView(
                                      child: AddContactBottomSheet(
                                        names: names,
                                        onAdd: (String name,
                                            String contact,
                                            String category,
                                            String message) async {
                                          try {
                                            // Get the current user's ID
                                            String userID = FirebaseAuth
                                                .instance.currentUser!.uid;

                                            // Create a new list to store messages
                                            List<Map<String, dynamic>>
                                                messages = [];

                                            // Add sample messages to the list
                                            messages.add({
                                              'content': message,
                                              'timestamp': DateTime.now(),
                                            });

                                            int activityStatus = 1;
                                            bool important = false;
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(userID)
                                                .collection('contacts')
                                                .doc(category.toLowerCase())
                                                .collection('contactList')
                                                .doc(contact)
                                                .set({
                                              'name': name,
                                              'contact': contact,
                                              'timestamp': DateTime.now(),
                                              'messages': messages,
                                              'status':
                                                  activityStatus,
                                              'important': important,
                                            });

                                            print(
                                                'Contact and messages added successfully');
                                          } catch (error) {
                                            print(
                                                'Error adding contact and messages: $error');
                                          }
                                        },
                                        callNumber: call.number ?? '',
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
