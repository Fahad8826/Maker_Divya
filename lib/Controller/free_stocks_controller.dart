import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FreeStocksController extends GetxController {
  final CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('products');

  // Reactive search query
  final RxString searchQuery = ''.obs;

  // Observable for the list of products (to reactively update the UI)
  final RxList<Map<String, dynamic>> _allProducts = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get allProducts => _allProducts.value;

  // Track the currently active editing controller and its product ID
  RxString _editingProductId = ''.obs; // The ID of the product being edited
  TextEditingController? _activeStockController; // The controller for the product being edited
  FocusNode? _activeFocusNode; // <--- ADD THIS: FocusNode for the active TextField

  // SharedPreferences instance
  late SharedPreferences _prefs;
  static const String _productsCacheKey = 'cached_products';
  static const String _cacheTimestampKey = 'cache_timestamp';
  static const int _cacheDuration = 5 * 60 * 1000; // Cache for 5 minutes

  @override
  void onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    await _loadCachedProducts(); // Load from cache or fetch from Firestore
  }

  @override
  void onClose() {
    _activeStockController?.dispose(); // Dispose the currently active controller if any
    _activeFocusNode?.dispose(); // <--- ADD THIS: Dispose the active FocusNode
    super.onClose();
  }

  // --- Helper methods for Caching ---
  Map<String, dynamic> _convertFirestoreData(Map<String, dynamic> data) {
    final Map<String, dynamic> convertedData = {};
    data.forEach((key, value) {
      if (value is Timestamp) {
        convertedData[key] = value.millisecondsSinceEpoch;
      } else if (value is DocumentReference) {
        convertedData[key] = value.path;
      } else if (value is GeoPoint) {
        convertedData[key] = {
          'latitude': value.latitude,
          'longitude': value.longitude,
        };
      } else {
        convertedData[key] = value;
      }
    });
    return convertedData;
  }

  // Helper method to convert serializable data back to Firestore format (not strictly needed for UI, but good for completeness if you write back from cache)
  Map<String, dynamic> _convertFromSerializable(Map<String, dynamic> data) {
    final Map<String, dynamic> convertedData = {};
    data.forEach((key, value) {
      if (value is int && (key.contains('time') || key.contains('date') || key.contains('created') || key.contains('updated'))) {
        convertedData[key] = Timestamp.fromMillisecondsSinceEpoch(value);
      } else if (value is Map<String, dynamic> && value.containsKey('latitude') && value.containsKey('longitude')) {
        convertedData[key] = GeoPoint(value['latitude'], value['longitude']);
      } else {
        convertedData[key] = value;
      }
    });
    return convertedData;
  }

  Future<void> _loadCachedProducts() async {
    final cachedData = _prefs.getString(_productsCacheKey);
    final cacheTimestamp = _prefs.getInt(_cacheTimestampKey) ?? 0;

    if (cachedData != null &&
        DateTime.now().millisecondsSinceEpoch - cacheTimestamp < _cacheDuration) {
      try {
        final List<dynamic> cachedProducts = jsonDecode(cachedData);
        // Update _allProducts RxList with cached data
        _allProducts.value = cachedProducts.map((e) => e as Map<String, dynamic>).toList();
      } catch (e) {
        _showErrorSnackbar('Error loading cached products.');
        await _fetchAndCacheProducts();
      }
    } else {
      await _fetchAndCacheProducts();
    }
  }

  Future<void> _fetchAndCacheProducts() async {
    try {
      final snapshot = await productsCollection.get();
      final List<Map<String, dynamic>> productList = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final convertedData = _convertFirestoreData(data);
        productList.add({'doc_id': doc.id, ...convertedData}); // Use a unique key like 'doc_id' for Firestore document ID
      }

      await _prefs.setString(_productsCacheKey, jsonEncode(productList));
      await _prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      _allProducts.value = productList; // Update the reactive list
    } catch (e) {
      _showErrorSnackbar('Failed to fetch products: $e');
      _allProducts.value = []; // Clear products on error
    }
  }

  // --- Stock Editing Logic ---

  // Check if a specific product is currently being edited
  bool isEditing(String productId) => _editingProductId.value == productId;

  // Get the TextEditingController AND FocusNode for the product currently being edited
  Map<String, dynamic>? getActiveStockControllerBundle() {
    if (_activeStockController != null && _activeFocusNode != null) {
      return {
        'controller': _activeStockController!,
        'focusNode': _activeFocusNode!,
      };
    }
    return null;
  }

  // Initiate editing for a product
  void startEditing(String productId, int initialStock) {
    // If another product is being edited, prevent starting a new edit
    if (_editingProductId.value.isNotEmpty && _editingProductId.value != productId) {
      _showInfoSnackbar('Please complete the current stock update first.');
      return;
    }

    // If this product is already being edited, do nothing (or clear for toggle behavior)
    if (_editingProductId.value == productId) {
      clearEditing();
      return;
    }

    // Dispose of any previous active controller and focus node
    _activeStockController?.dispose();
    _activeFocusNode?.dispose(); // <--- ADD THIS: Dispose old FocusNode
    
    // Set the new active controller and product ID
    _activeStockController = TextEditingController(text: initialStock.toString());
    _activeFocusNode = FocusNode(); // <--- ADD THIS: Create new FocusNode
    _editingProductId.value = productId;
  }

  // Clear the current editing state
  void clearEditing() {
    _activeStockController?.dispose();
    _activeStockController = null;
    _activeFocusNode?.dispose(); // <--- ADD THIS: Dispose FocusNode
    _activeFocusNode = null;
    _editingProductId.value = '';
  }

  // Update stock in Firestore and refresh UI
  Future<void> updateStock(String productId, int newStock) async {
    if (newStock < 0) {
      _showErrorSnackbar('Stock cannot be negative');
      return;
    }

    try {
      await productsCollection.doc(productId).update({'stock': newStock});
      HapticFeedback.lightImpact();
      _showSuccessSnackbar('Stock updated successfully');

      // Update the stock in our local reactive list
      final index = _allProducts.indexWhere((p) => p['doc_id'] == productId);
      if (index != -1) {
        _allProducts[index]['stock'] = newStock;
        _allProducts.refresh(); // Notify Obx listeners
      }

      await _fetchAndCacheProducts(); // Re-cache the updated data
    } catch (e) {
      _showErrorSnackbar('Failed to update stock: $e');
    } finally {
      clearEditing(); // Always clear editing state after an attempt
    }
  }

  // Refresh products from Firestore and update cache
  Future<void> refreshProducts() async {
    searchQuery.value = ''; // Clear search query on refresh
    clearEditing(); // Clear any active editing on refresh
    await _fetchAndCacheProducts();
    HapticFeedback.lightImpact();
  }

  // --- Snackbar Helpers ---
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Oops!',
      message,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      animationDuration: const Duration(milliseconds: 300),
      duration: const Duration(seconds: 3),
    );
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      animationDuration: const Duration(milliseconds: 300),
      duration: const Duration(seconds: 2),
    );
  }

  void _showInfoSnackbar(String message) {
    Get.snackbar(
      'Notice',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade700,
    );
  }
}