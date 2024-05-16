import 'package:flutter/material.dart';
import 'package:leadboard_app/screens/Dashboard/DashboarScreens/LeadScreen/lead_screen.dart';

class GridViewSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<String> names = ["Commercial", "Industrial", "Residential", "Rental", "Others"];
    List<String> imageUrls = [
      "assets/images/commercial.png",
      "assets/images/industrial.png",
      "assets/images/residential.png",
      "assets/images/rent.png",
      "assets/images/others.png",
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: List.generate(names.length, (index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    name: names[index],
                    imageUrl: imageUrls[index],
                  ),
                ),
              );
            },
            child: BoxItem(
              name: names[index],
              imageUrl: imageUrls[index],
            ),
          );
        }),
      ),
    );
  }
}

class BoxItem extends StatelessWidget {
  final String name;
  final String imageUrl;

  const BoxItem({
    required this.name,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 10),
          Image.asset(
            imageUrl,
            width: 100,
            height: 100,
          ),
        ],
      ),
    );
  }
}

