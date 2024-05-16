import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leadboard_app/screens/Dashboard/DashboarScreens/LeadScreen/chat_screen.dart';
import 'package:leadboard_app/screens/Dashboard/DashboarScreens/grid_screen.dart';
import 'package:leadboard_app/screens/Dashboard/DashboarScreens/horizontal_grid.dart';
import 'package:leadboard_app/screens/drawer_screen.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? userName;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        userName = userSnapshot['username'];
      });
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      String userID = FirebaseAuth.instance.currentUser!.uid;

      FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('contacts')
          .get()
          .then((contactsSnapshot) {
        setState(() {
          searchResults.clear();
        });

        contactsSnapshot.docs.forEach((contactDoc) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(userID)
              .collection('contacts')
              .doc(contactDoc.id)
              .collection('contactList')
              .get()
              .then((contactListSnapshot) {
            contactListSnapshot.docs.forEach((detailDoc) {
              var detailData = detailDoc.data();
              String name = detailData['name'].toString().toLowerCase();
              String contact = detailData['contact'].toString().toLowerCase();
              int status = detailData['status'];
              if (name.contains(query.toLowerCase()) ||
                  contact.contains(query.toLowerCase())) {
                setState(() {
                  searchResults.add({
                    'name': detailData['name'],
                    'contact': detailData['contact'],
                    'category': contactDoc.id,
                    'status': status,
                  });
                  isSearching = true;
                });
              }
            });
          }).catchError((error) {});
        });
      }).catchError((error) {});
    } else {
      setState(() {
        searchResults.clear();
        isSearching = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> loadMessages(
      String catogery, String phoneNumber) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    List<Map<String, dynamic>> messages = [];
    print(catogery);

    DocumentReference contactDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .collection('contacts')
        .doc(catogery)
        .collection('contactList')
        .doc(phoneNumber);

    try {
      DocumentSnapshot contactSnapshot = await contactDoc.get();

      if (contactSnapshot.exists) {
        dynamic data = contactSnapshot.data();
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

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var greeting = _getGreeting(now.hour);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _scaffoldKey.currentState!.openDrawer();
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/profile.png'),
                  radius: 20,
                ),
              ),
            ),
            const Spacer(),
            const Text(
              'LeadBoard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // Add your notification functionality here
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      drawer: Drawer(
        child: DrawerContent(
          userName: userName,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            isSearching = false;
            _searchController.clear();
          });
        },
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    const Color.fromARGB(255, 246, 76, 133).withOpacity(0.2)
                  ],
                  stops: [0.4, 0.8],
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        '$greeting, ${userName ?? "User"}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        onTap: () {
                          setState(() {
                            isSearching =
                                true; 
                          });
                        },
                        controller: _searchController,
                        onChanged: (value) {
                          _performSearch(value);
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Search...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (isSearching)
                      Container(
                        height: 200,
                        child: ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () async {
                                List<Map<String, dynamic>> messages =
                                    await loadMessages(
                                        searchResults[index]['category'],
                                        searchResults[index]['contact']);

                                print(searchResults[index]['name']);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                        name: searchResults[index]['name'],
                                        phoneNumber: searchResults[index]
                                            ['contact'],
                                        category:
                                            "searchResults[index]['category']",
                                        messages: messages,
                                        status: searchResults[index]['status']),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      searchResults[index]['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      searchResults[index]['contact'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 10),
                    HorizontalListView(),
                    const SizedBox(height: 10),
                    GridViewSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
