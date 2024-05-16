import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:leadboard_app/reusable_widgets/dummy.dart';

class CircleChart extends StatelessWidget {
  const CircleChart({
    required this.categories,
  });

  final List<CategoryData> categories;

  List<PieChartSectionData> generateSections(List<CategoryData> categories) {
    List<PieChartSectionData> sections = [];

    // Iterate over categories to generate PieChartSectionData
    for (int i = 0; i < categories.length; i++) {
      // Calculate percentage for each category
      double percent =
          categories[i].contactCount / getTotalContacts(categories);

      sections.add(
        PieChartSectionData(
          color: categories[i].color,
          value: percent * 100, // Convert to percentage
          radius: 20,
          title: '',
        ),
      );
    }

    return sections;
  }

  int getTotalContacts(List<CategoryData> categories) {
    int totalContacts = 0;

    // Iterate over categories to sum up contact counts
    for (int i = 0; i < categories.length; i++) {
      totalContacts += categories[i].contactCount;
    }

    return totalContacts;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                PieChart(
                  PieChartData(
                    startDegreeOffset: 270,
                    sectionsSpace: 0,
                    centerSpaceRadius: 60,
                    sections: generateSections(categories),
                  ),
                ),
                const Text(
                  'Contacts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width:40),
          // Display category names and contact counts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categories.map((category) {
                return _CircleChartBottomInfo(
                  text: category.name,
                  color: category.color,
                  totalPercent: category.contactCount.toDouble(),
                  growthPercent: 0, // You can modify this if needed
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleChartBottomInfo extends StatelessWidget {
  const _CircleChartBottomInfo({
    required this.text,
    required this.color,
    required this.growthPercent,
    required this.totalPercent,
    this.haveIncreased = true,
  });

  final String text;
  final Color color;
  final double totalPercent;
  final double growthPercent;
  final bool haveIncreased;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: color,
            radius: 9,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              Text(
                '${totalPercent.toInt()} contacts',
                style: TextStyle(fontSize: 10, color: const Color.fromARGB(255, 90, 89, 89)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


