import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/notification_service.dart';

class TaskRepository {
  final CollectionReference _tasksCollection = FirebaseFirestore.instance
      .collection('tasks');

  // Create a new task and return its ID
  Future<String> createTask(TaskModel task) async {
    final docRef = _tasksCollection.doc();
    final taskWithId = task.copyWith(id: docRef.id);
    await docRef.set(taskWithId.toMap());
    
    // Automatically schedule notification on creation
    if (task.deadline != null) {
      await NotificationService().scheduleTaskNotification(taskWithId);
    }
    
    return docRef.id;
  }

  // Get stream of tasks for a user
  Stream<List<TaskModel>> getTasksStream(String userId) {
    return _tasksCollection.where('user_id', isEqualTo: userId).snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      },
    );
  }

  // Update task completion status
  Future<void> updateTaskCompletion(String taskId, bool isCompleted) async {
    await _tasksCollection.doc(taskId).update({'is_completed': isCompleted});
    
    // If marked completed, cancel reminder. If reactivated, reschedule it.
    if (isCompleted) {
      await NotificationService().cancelNotification(taskId);
    } else {
      try {
        final doc = await _tasksCollection.doc(taskId).get();
        if (doc.exists) {
          final task = TaskModel.fromFirestore(doc);
          await NotificationService().scheduleTaskNotification(task);
        }
      } catch (e) {
        debugPrint('Failed to reschedule task notification on activation: $e');
      }
    }
  }

  // Update task pin status
  Future<void> updateTaskPin(String taskId, bool isPinned) async {
    await _tasksCollection.doc(taskId).update({'is_pinned': isPinned});
  }

  // Update task details
  Future<void> updateTask(TaskModel task) async {
    await _tasksCollection.doc(task.id).update(task.toMap());
    
    // Update or cancel notification depending on updated deadline
    if (task.deadline != null && !task.isCompleted) {
      await NotificationService().scheduleTaskNotification(task);
    } else {
      await NotificationService().cancelNotification(task.id);
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
    await NotificationService().cancelNotification(taskId);
  }
}
