import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/notification_service.dart';

class TaskRepository {
  final CollectionReference _tasksCollection = FirebaseFirestore.instance
      .collection('tasks');

  // Membuat tugas baru dan mengembalikan ID-nya
  Future<String> createTask(TaskModel task) async {
    final docRef = _tasksCollection.doc();
    final taskWithId = task.copyWith(id: docRef.id);
    await docRef.set(taskWithId.toMap());
    
    // Jadwalkan notifikasi secara otomatis saat tugas dibuat
    if (task.deadline != null) {
      await NotificationService().scheduleTaskNotification(taskWithId);
    }
    
    return docRef.id;
  }

  // Mengambil stream tugas milik seorang pengguna
  Stream<List<TaskModel>> getTasksStream(String userId) {
    return _tasksCollection.where('user_id', isEqualTo: userId).snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      },
    );
  }

  // Memperbarui status penyelesaian tugas
  Future<void> updateTaskCompletion(String taskId, bool isCompleted) async {
    await _tasksCollection.doc(taskId).update({'is_completed': isCompleted});
    
    // Jika ditandai selesai, batalkan pengingat. Jika diaktifkan kembali, jadwalkan ulang.
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
        debugPrint('Gagal menjadwalkan ulang notifikasi tugas saat diaktifkan: $e');
      }
    }
  }

  // Memperbarui status pin tugas
  Future<void> updateTaskPin(String taskId, bool isPinned) async {
    await _tasksCollection.doc(taskId).update({'is_pinned': isPinned});
  }

  // Memperbarui detail tugas
  Future<void> updateTask(TaskModel task) async {
    await _tasksCollection.doc(task.id).update(task.toMap());
    
    // Perbarui atau batalkan notifikasi tergantung tenggat yang diperbarui
    if (task.deadline != null && !task.isCompleted) {
      await NotificationService().scheduleTaskNotification(task);
    } else {
      await NotificationService().cancelNotification(task.id);
    }
  }

  // Menghapus tugas
  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
    await NotificationService().cancelNotification(taskId);
  }

  // Memulihkan tugas yang sebelumnya dihapus (dipakai untuk aksi urungkan "Urungkan")
  Future<void> restoreTask(TaskModel task) async {
    await _tasksCollection.doc(task.id).set(task.toMap());

    if (task.deadline != null && !task.isCompleted) {
      await NotificationService().scheduleTaskNotification(task);
    }
  }
}
