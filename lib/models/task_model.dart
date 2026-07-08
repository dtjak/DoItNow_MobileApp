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

  /// Membuat TaskModel dari snapshot dokumen Firestore (READ).
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

  /// Mengubah tugas ini menjadi map biasa untuk ditulis ke Firestore (CREATE/UPDATE).
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

  /// Mengembalikan salinan tugas ini dengan field yang diberikan diganti.
  TaskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    String? priority,
    DateTime? deadline,
    bool? isPinned,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      isPinned: isPinned ?? this.isPinned,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
