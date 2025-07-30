import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ResponseController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable states
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxList<DocumentSnapshot> _cachedResponses = <DocumentSnapshot>[].obs;

  // Cache for admin emails to avoid repeated Firestore calls
  final Map<String, String> _adminEmailCache = {};

  // Getters
  String? get currentUserId => _auth.currentUser?.uid;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  List<DocumentSnapshot> get cachedResponses => _cachedResponses;

  @override
  void onInit() {
    super.onInit();
    _initializeAuthListener();
  }

  @override
  void onClose() {
    _adminEmailCache.clear();
    super.onClose();
  }

  /// Initialize authentication state listener
  void _initializeAuthListener() {
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        _cachedResponses.clear();
        _adminEmailCache.clear();
      }
    });
  }

  /// Stream for real-time response updates
  Stream<QuerySnapshot> get responseStream {
    if (currentUserId == null) {
      return Stream.empty();
    }

    return _firestore
        .collection('complaint_responses')
        .where('statusChanged', isEqualTo: true)
        .where('userId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .handleError((error) {
          _handleError('Failed to load responses', error);
        });
  }

  /// Refresh responses manually
  Future<void> refreshResponses() async {
    if (currentUserId == null) {
      _handleError('User not authenticated', null);
      return;
    }

    try {
      _isLoading.value = true;
      _hasError.value = false;
      _errorMessage.value = '';

      // Clear cache to ensure fresh data
      _adminEmailCache.clear();

      // Fetch fresh data
      final QuerySnapshot snapshot = await _firestore
          .collection('complaint_responses')
          .where('statusChanged', isEqualTo: true)
          .where('userId', isEqualTo: currentUserId)
          .orderBy('timestamp', descending: true)
          .get();

      _cachedResponses.assignAll(snapshot.docs);

      // Preload admin emails for better performance
      await _preloadAdminEmails(snapshot.docs);

      // Show success message
      Get.snackbar(
        'Success',
        'Responses refreshed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[700],
        icon: const Icon(Icons.check_circle, color: Colors.green),
        duration: const Duration(seconds: 2),
      );
    } catch (error) {
      _handleError('Failed to refresh responses', error);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Preload admin emails for better performance
  Future<void> _preloadAdminEmails(List<DocumentSnapshot> docs) async {
    final Set<String> adminIds = {};

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>?;
      final adminId = data?['respondedBy'] as String?;
      if (adminId != null && !_adminEmailCache.containsKey(adminId)) {
        adminIds.add(adminId);
      }
    }

    // Batch load admin emails
    await Future.wait(
      adminIds.map((adminId) => _fetchAndCacheAdminEmail(adminId)),
    );
  }

  /// Fetch and cache admin email
  Future<void> _fetchAndCacheAdminEmail(String adminId) async {
    try {
      final doc = await _firestore.collection('admin').doc(adminId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final email =
            data['email'] ??
            data['Email'] ??
            data['emailAddress'] ??
            data['userEmail'] ??
            'Unknown Admin';
        _adminEmailCache[adminId] = email;
      } else {
        _adminEmailCache[adminId] = 'Admin Not Found';
      }
    } catch (e) {
      _adminEmailCache[adminId] = 'Error Loading Admin';
    }
  }

  /// Get admin email with caching
  Future<String> getAdminEmail(String? adminId) async {
    if (adminId == null || adminId.isEmpty) {
      return 'Unknown Admin';
    }

    // Return cached email if available
    if (_adminEmailCache.containsKey(adminId)) {
      return _adminEmailCache[adminId]!;
    }

    try {
      final doc = await _firestore
          .collection('admin')
          .doc(adminId)
          .get()
          .timeout(const Duration(seconds: 10));

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final email =
            data['email'] ??
            data['Email'] ??
            data['emailAddress'] ??
            data['userEmail'] ??
            'Unknown Admin';

        // Cache the result
        _adminEmailCache[adminId] = email;
        return email;
      } else {
        _adminEmailCache[adminId] = 'Admin Not Found';
        return 'Admin Not Found';
      }
    } catch (e) {
      _adminEmailCache[adminId] = 'Error Loading Admin';
      return 'Error Loading Admin';
    }
  }

  /// Format timestamp with better formatting
  String formatTimestamp(dynamic timestamp) {
    try {
      DateTime dateTime;

      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is DateTime) {
        dateTime = timestamp;
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return 'Invalid Date';
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      // Show relative time for recent responses
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else {
        // Show formatted date for older responses
        return DateFormat('MMM dd, yyyy \'at\' h:mm a').format(dateTime);
      }
    } catch (e) {
      return 'Invalid Date';
    }
  }

  /// Get absolute timestamp for tooltips or detailed view
  String getAbsoluteTimestamp(dynamic timestamp) {
    try {
      DateTime dateTime;

      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is DateTime) {
        dateTime = timestamp;
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return 'Invalid Date';
      }

      return DateFormat('EEEE, MMMM dd, yyyy \'at\' h:mm a').format(dateTime);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  /// Enhanced status color with theme support
  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'resolved':
      case 'completed':
        return Colors.green;
      case 'in-progress':
      case 'in_progress':
      case 'processing':
        return Colors.orange;
      case 'pending':
      case 'submitted':
        return Colors.amber;
      case 'rejected':
      case 'declined':
        return Colors.red;
      case 'cancelled':
      case 'canceled':
        return Colors.grey;
      case 'under_review':
      case 'reviewing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// Enhanced status icon
  IconData getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'resolved':
      case 'completed':
        return Icons.check_circle_rounded;
      case 'in-progress':
      case 'in_progress':
      case 'processing':
        return Icons.hourglass_empty_rounded;
      case 'pending':
      case 'submitted':
        return Icons.pending_rounded;
      case 'rejected':
      case 'declined':
        return Icons.cancel_rounded;
      case 'cancelled':
      case 'canceled':
        return Icons.block_rounded;
      case 'under_review':
      case 'reviewing':
        return Icons.visibility_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  /// Mark response as read
  Future<void> markResponseAsRead(String documentId) async {
    try {
      await _firestore.collection('complaint_responses').doc(documentId).update(
        {'isRead': true, 'readAt': FieldValue.serverTimestamp()},
      );
    } catch (e) {
      debugPrint('Error marking response as read');
    }
  }

  /// Get unread responses count
  Future<int> getUnreadCount() async {
    if (currentUserId == null) return 0;

    try {
      final snapshot = await _firestore
          .collection('complaint_responses')
          .where('userId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting unread count');
      return 0;
    }
  }

  /// Handle errors consistently
  void _handleError(String message, r) {
    _hasError.value = true;
    _errorMessage.value = message;

    debugPrint('ResponseController ');

    Get.snackbar(
      'Oops!',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red[700],
      icon: const Icon(Icons.error, color: Colors.red),
      duration: const Duration(seconds: 3),
    );
  }

  /// Clear error state
  void clearError() {
    _hasError.value = false;
    _errorMessage.value = '';
  }
}
