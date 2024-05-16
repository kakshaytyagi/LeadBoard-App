import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leadboard_app/screens/Dashboard/CallScreens/add_contact.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<String> names = [
    "Commercial",
    "Industrial",
    "Residential",
    "Rental",
    "Others"
  ];
  String selectedCategory = "Commercial";
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getContactPermission();
  }

  void getContactPermission() async {
    final PermissionStatus permissionStatus =
        await Permission.contacts.request();
    if (permissionStatus.isGranted) {
      fetchContacts();
    } else {
      // Handle permissions denied
      // You might want to display a message or take appropriate action
    }
  }

  void fetchContacts() async {
    try {
      Iterable<Contact> contactList = await ContactsService.getContacts();
      setState(() {
        contacts = contactList.toList();
        filteredContacts = contacts;
        isLoading = false;
      });
    } catch (e) {
      // Handle exception
      print('Error fetching contacts: $e');
    }
  }

  void filterContacts(String query) {
    List<Contact> filteredList = contacts.where((contact) {
      final String displayName = contact.displayName ?? '';
      final List<Item>? phones = contact.phones;

      // Check if the contact name or any phone number matches the query
      bool nameMatches =
          displayName.toLowerCase().contains(query.toLowerCase());
      bool phoneMatches = false;

      if (phones != null) {
        for (Item phone in phones) {
          if (phone.value!.toLowerCase().contains(query.toLowerCase())) {
            phoneMatches = true;
            break;
          }
        }
      }

      return nameMatches || phoneMatches;
    }).toList();

    setState(() {
      filteredContacts = filteredList;
    });
  }

  void addContact() async {
    // Create a new contact
    Contact newContact = Contact(
      displayName: 'New Contact',
      phones: [Item(label: 'mobile', value: '1234567890')],
    );

    // Save the new contact
    await ContactsService.addContact(newContact);

    // Refresh the contacts list
    fetchContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: filterContacts,
              decoration: InputDecoration(
                hintText: "Search Contacts...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      Contact contact = filteredContacts[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            leading: Container(
                              height: 60,
                              width: 60,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.grey[200],
                              ),
                              child: Text(
                                contact.displayName?.isNotEmpty ?? false
                                    ? contact.displayName![0]
                                    : '',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.primaries[Random()
                                      .nextInt(Colors.primaries.length)],
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            title: Text(
                              contact.displayName ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              contact.phones!.isNotEmpty
                                  ? contact.phones!.elementAt(0).value!
                                  : 'No phone number',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            horizontalTitleGap: 12,
                            trailing: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      elevation: 0,
                                      backgroundColor: Colors.transparent,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                          borderRadius:
                                              BorderRadius.circular(20),
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
                                                  'status': activityStatus,
                                                  'important': important,
                                                });

                                                print(
                                                    'Contact and messages added successfully');
                                              } catch (error) {
                                                print(
                                                    'Error adding contact and messages: $error');
                                              }
                                            },
                                            callNumber:
                                                contact.phones!.isNotEmpty
                                                    ? contact.phones!
                                                        .elementAt(0)
                                                        .value!
                                                    : 'No phone number',
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
