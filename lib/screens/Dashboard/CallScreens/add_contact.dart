import 'package:flutter/material.dart';

class AddContactBottomSheet extends StatefulWidget {
  final List<String> names;
  final Function(String name, String contact, String category, String message)
      onAdd;
  final String callNumber;

  const AddContactBottomSheet({
    Key? key,
    required this.names,
    required this.onAdd,
    required this.callNumber,
  }) : super(key: key);

  @override
  _AddContactBottomSheetState createState() => _AddContactBottomSheetState();
}

class _AddContactBottomSheetState extends State<AddContactBottomSheet> {
  String selectedCategory = "";
  TextEditingController nameController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.names.first;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {},
          ),
          SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              labelText: 'Contact',
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(text: widget.callNumber),
            onChanged: (value) {},
          ),
          SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              prefixIcon: Icon(Icons.category),
            ),
            items: widget.names.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedCategory = newValue!;
              });
            },
          ),
          SizedBox(height: 20),
          TextField(
            controller: messageController,
            maxLines: 3, // Set maximum lines to 3
            decoration: InputDecoration(
              labelText: 'Message...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {},
          ),
          SizedBox(height: 20),
          Divider(),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TextButton(
              onPressed: () {
                widget.onAdd(
                  nameController.text.isEmpty ? "Unknown" : nameController.text,
                  widget.callNumber,
                  selectedCategory,
                  messageController.text.isEmpty
                      ? "Let's talk"
                      : messageController.text,
                );
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.blue,
              ),
              child: Text(
                'ADD',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
