import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Contact {
  final String name;
  final String phoneNumber;
  final String lastMessage;
  final int status;

  Contact({
    required this.name,
    required this.phoneNumber,
    required this.lastMessage,
    required this.status,
  });
}

class ImpContact {
  final String name;
  final String phoneNumber;
  final String lastMessage;
  final int status;
  final String category;

  ImpContact({
    required this.name,
    required this.phoneNumber,
    required this.lastMessage,
    required this.status,
    required this.category,
  });
}

class CategoryData {
  final String name;
  final int contactCount;
  final Color color;

  CategoryData({
    required this.name,
    required this.contactCount,
    required this.color,
  });
}

List<CategoryData> categoryData = [];

class StatusData {
  final int contactCount;
  final int active;
  final int dead;
  final int neutral;

  StatusData({
    required this.contactCount,
    required this.active,
    required this.dead,
    required this.neutral,
  });
}

List<StatusData> statusData = [];

class ReContact {
  final String name;
  final String phoneNumber;
  final String lastMessage;
  final int status;
  final Timestamp timestamp;

  ReContact({
    required this.name,
    required this.phoneNumber,
    required this.lastMessage,
    required this.status,
    required this.timestamp,
  });
}
