import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String priority;
  final DateTime? deadline;
  final bool isPinned;
  final bool isCompleted;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    this.deadline,
    this.isPinned = false,
    this.isCompleted = false,
    required this.createdAt,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      userId: data['user_id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Kampus',
      priority: data['priority'] ?? 'High',
      deadline: data['deadline'] != null
          ? (data['deadline'] as Timestamp).toDate()
          : null,
      isPinned: data['is_pinned'] ?? false,
      isCompleted: data['is_completed'] ?? false,
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'is_pinned': isPinned,
      'is_completed': isCompleted,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
