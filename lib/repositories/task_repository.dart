import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskRepository {
  final CollectionReference _tasksCollection = FirebaseFirestore.instance
      .collection('tasks');

  // Create a new task
  Future<void> createTask(TaskModel task) async {
    await _tasksCollection.add(task.toMap());
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
  }

  // Update task pin status
  Future<void> updateTaskPin(String taskId, bool isPinned) async {
    await _tasksCollection.doc(taskId).update({'is_pinned': isPinned});
  }

  // Update task details
  Future<void> updateTask(TaskModel task) async {
    await _tasksCollection.doc(task.id).update(task.toMap());
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }
}
