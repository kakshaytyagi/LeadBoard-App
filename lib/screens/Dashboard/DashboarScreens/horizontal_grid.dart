import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leadboard_app/reusable_widgets/dummy.dart';
import 'package:leadboard_app/screens/Dashboard/DashboarScreens/GridScreen/bar_chart.dart';

enum CategoryType { Active, Dead, Neutral }

class HorizontalListView extends StatefulWidget {
  @override
  _HorizontalListViewState createState() => _HorizontalListViewState();
}

class _HorizontalListViewState extends State<HorizontalListView> {
  PageController _pageController = PageController(
    viewportFraction: 0.8,
    initialPage: 1,
  );
  int _currentPage = 1;
  List<CategoryData> categoryData = [];
  StatusData statusData =
      StatusData(contactCount: 0, active: 0, dead: 0, neutral: 0);
  List<ReContact> recentActiveContacts = [];

  @override
  void initState() {
    super.initState();
    CategoryDataSearch();
    getContactCount();
    fetchRecentActiveContacts();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchRecentActiveContacts() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    Timestamp sevenDaysAgo = Timestamp.fromDate(
      DateTime.now().subtract(Duration(days: 7)),
    );

    try {
      QuerySnapshot contactsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('contacts')
          .get();

      List<ReContact> tempRecentActiveContacts = [];

      List<Future<void>> futures =
          contactsSnapshot.docs.map((contactDoc) async {
        QuerySnapshot contactListSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .collection('contacts')
            .doc(contactDoc.id)
            .collection('contactList')
            .get();

        for (DocumentSnapshot detailDoc in contactListSnapshot.docs) {
          var detailData = detailDoc.data() as Map<String, dynamic>;
          String name = detailData['name'];
          String number = detailData['contact'];
          int status = detailData['status'];
          Timestamp timestamp = detailData['timestamp'];
          print(timestamp);

          if (status == 1 && timestamp.compareTo(sevenDaysAgo) > 0) {
            tempRecentActiveContacts.add(ReContact(
              name: name,
              phoneNumber: number,
              lastMessage: "Hello world",
              status: status,
              timestamp: timestamp,
            ));
          }
        }
      }).toList();

      await Future.wait(futures);

      tempRecentActiveContacts
          .sort((a, b) => b.timestamp.compareTo(a.timestamp));

      setState(() {
        recentActiveContacts = tempRecentActiveContacts.length > 3
            ? tempRecentActiveContacts.sublist(0, 3)
            : tempRecentActiveContacts;
      });
    } catch (error) {
      print('Error fetching contact count: $error');
    }
  }

  Future<void> CategoryDataSearch() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    List<Color> colorList = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
    ];

    int colorIndex = 0;

    try {
      QuerySnapshot contactsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('contacts')
          .get();

      List<Future<void>> futures = [];

      setState(() {
        categoryData.clear();
      });

      for (DocumentSnapshot contactDoc in contactsSnapshot.docs) {
        futures.add(
          FirebaseFirestore.instance
              .collection('users')
              .doc(userID)
              .collection('contacts')
              .doc(contactDoc.id)
              .collection('contactList')
              .get()
              .then((contactListSnapshot) {
            int contactCount = contactListSnapshot.size;
            Color color = colorList[colorIndex % colorList.length];
            setState(() {
              categoryData.add(CategoryData(
                name: contactDoc.id,
                contactCount: contactCount,
                color: color,
              ));
              colorIndex++;
            });
          }),
        );
      }

      await Future.wait(futures);

      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      print('Error fetching category data: $error');
    }
  }

  Future<void> getContactCount() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;

    try {
      QuerySnapshot contactsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('contacts')
          .get();

      List<Future<void>> futures = [];

      int activeCount = 0;
      int deadCount = 0;
      int neutralCount = 0;
      int totalContacts = 0;

      for (DocumentSnapshot contactDoc in contactsSnapshot.docs) {
        futures.add(
          FirebaseFirestore.instance
              .collection('users')
              .doc(userID)
              .collection('contacts')
              .doc(contactDoc.id)
              .collection('contactList')
              .get()
              .then((contactListSnapshot) {
            int contactCount = contactListSnapshot.size;
            totalContacts += contactCount;
            for (DocumentSnapshot detailDoc in contactListSnapshot.docs) {
              var detailData = detailDoc.data() as Map<String, dynamic>;
              int status = detailData['status'];
              if (status == 1) {
                activeCount++;
              } else if (status == -1) {
                deadCount++;
              } else {
                neutralCount++;
              }
            }
          }),
        );
      }

      await Future.wait(futures);

      setState(() {
        statusData = StatusData(
          contactCount: totalContacts,
          active: activeCount,
          dead: deadCount,
          neutral: neutralCount,
        );
      });
    } catch (error) {
      print('Error fetching contact count: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 270,
          child: PageView.builder(
            controller: _pageController,
            itemCount: 3,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Color.fromARGB(255, 238, 233, 227),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total Contacts: ${statusData.contactCount}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildLight(Color(0xFFFFD700),
                                '${statusData.neutral} Neutral'),
                            _buildLight(
                                Color(0xFFFF0000), '${statusData.dead} Dead'),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLight(Color(0xFF00FF00),
                                '${statusData.active} Active'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else if (index == 1) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 87, 184, 90)!,
                        Color.fromARGB(255, 249, 250, 249)!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CircleChart(
                    categories: categoryData,
                  ),
                );
              } else {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    itemCount: recentActiveContacts.length,
                    itemBuilder: (context, index) {
                      ReContact contact = recentActiveContacts[index];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: Colors.grey[300]!, width: 0.5),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor:
                                Colors.blue, // Customize the color as needed
                            child: Text(
                              contact.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            contact.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            contact.phoneNumber,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: buildColor(Color(0xFF00FF00)),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? Color.fromARGB(255, 122, 61, 245)
                    : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLight(Color color, String text) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 18, // Adjust the size as needed
            backgroundColor: color,
          ),
        ),
        SizedBox(height: 10),
        Text(
          text,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget buildColor(Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 10, // Adjust the size as needed
            backgroundColor: color,
          ),
        ),
      ],
    );
  }
}
