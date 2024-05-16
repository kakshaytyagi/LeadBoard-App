import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String phoneNumber;
  final String category;
  final List<Map<String, dynamic>> messages;
  int status;

  ChatScreen({
    required this.name,
    required this.phoneNumber,
    required this.category,
    required this.messages,
    required this.status,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];

  // Define a ScrollController
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages = widget.messages;
    WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void _showLightColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Light Color'),
          content: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLightColorOption('Red', -1),
                _buildLightColorOption('Yellow', 0),
                _buildLightColorOption('Green', 1),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLightColorOption(String label, int colorCode) {
    return GestureDetector(
      onTap: () {
        _updateLightColor(colorCode);
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: colorCode == -1
                ? Colors.red
                : colorCode == 0
                    ? Colors.yellow
                    : Colors.green,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 12,
          backgroundColor: colorCode == -1
              ? Colors.red
              : colorCode == 0
                  ? Colors.yellow
                  : Colors.green,
        ),
      ),
    );
  }

  void _updateLightColor(int colorCode) async {
    try {
      // Get the current user's ID
      String userID = FirebaseAuth.instance.currentUser!.uid;

      // Update the status in Firebase Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('contacts')
          .doc(widget.category.toLowerCase())
          .collection('contactList')
          .doc(widget.phoneNumber)
          .update({
        'status': colorCode,
      });

      // Update the status locally
      setState(() {
        widget.status = colorCode;
      });
    } catch (error) {
      print('Error updating light color status: $error');
    }
  }

  Future<void> editContact(String phoneNumber, String newName) async {
    try {
      String userID = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('contacts')
          .doc(widget.category.toLowerCase())
          .collection('contactList')
          .doc(phoneNumber)
          .update({
        'name': newName,
      });
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (widget.name != "Unknown") ? widget.name : widget.phoneNumber,
        ),
        actions: [
          GestureDetector(
            onTap: () {
              _showLightColorPicker();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.status == -1
                        ? Colors.red
                        : widget.status == 0
                            ? Colors.yellow
                            : Colors.green,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 9,
                  backgroundColor: widget.status == -1
                      ? Colors.red
                      : widget.status == 0
                          ? Colors.yellow
                          : Colors.green,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Show dialog to edit the contact's name
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  String newName = widget.name; // Initialize with current name
                  return AlertDialog(
                    title: Text('Edit Name'),
                    content: TextField(
                      onChanged: (value) {
                        newName = value;
                      },
                      controller: TextEditingController(text: widget.name),
                      decoration: InputDecoration(
                        hintText: 'Enter new name',
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          print("Hello world i m here");
                          // Call the editContact function to update the contact's name
                          await editContact(widget.phoneNumber, newName);
                          Navigator.pop(context); // Close the dialog
                        },
                        child: Text('Save'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueGrey.withOpacity(0.2),
              Colors.white.withOpacity(0.9),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController, // Assign the ScrollController
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(index);
                },
              ),
            ),
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.transparent, // Set container color to transparent
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _sendMessage(_messageController.text);
              _messageController.clear();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(int index) {
    final message = _messages[index];
    final previousMessage = index > 0 ? _messages[index - 1] : null;
    final bool isNewDate =
        previousMessage == null || message['date'] != previousMessage['date'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isNewDate) ...[
          _buildDateHeader(message['date']),
          SizedBox(height: 8),
        ],
        _buildMessageContent(message),
      ],
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    String dateString;
    if (difference == 0) {
      dateString = 'Today';
    } else if (difference == 1) {
      dateString = 'Yesterday';
    } else {
      dateString = DateFormat('dd MMM yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        dateString,
        style: TextStyle(
          color: Color.fromARGB(255, 80, 77, 77),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMessageContent(Map<String, dynamic> message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message['sender'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          Text(
            message['text'],
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          Text(
            DateFormat('HH:mm').format(message['date']),
            style: TextStyle(
              fontSize: 12,
              color: const Color.fromARGB(255, 29, 26, 26),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String? text) async {
    if (text != null && text.isNotEmpty) {
      final currentTime = DateTime.now();

      try {
        final firestoreInstance = FirebaseFirestore.instance;

        final messageDocRef = firestoreInstance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('contacts')
            .doc(widget.category.toLowerCase())
            .collection('contactList')
            .doc(widget.phoneNumber);

        await messageDocRef.update({
          'messages': FieldValue.arrayUnion([
            {
              'sender': 'Customer',
              'content': text,
              'timestamp': currentTime,
            }
          ])
        });

        setState(() {
          _messages.add({
            'sender': 'Customer',
            'text': text,
            'date': currentTime,
          });
        });

        _scrollToBottom();
      } catch (error) {}
    } else {}
  }
}
