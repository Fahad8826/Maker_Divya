// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // GetX Controller for FreeStocks
// class FreeStocksController extends GetxController {
//   // Reference to the 'products' collection in Firestore
//   final CollectionReference products = FirebaseFirestore.instance.collection(
//     'products',
//   );

//   // Reactive map for TextEditingControllers
//   final RxMap<String, TextEditingController> stockControllers =
//       <String, TextEditingController>{}.obs;

//   // Reactive search query
//   final RxString searchQuery = ''.obs;

//   // SharedPreferences instance
//   late SharedPreferences _prefs;
//   static const String _productsCacheKey = 'cached_products';
//   static const String _cacheTimestampKey = 'cache_timestamp';
//   static const int _cacheDuration = 5 * 60 * 1000; // Cache for 5 minutes

//   @override
//   void onInit() async {
//     super.onInit();
//     // Initialize SharedPreferences
//     _prefs = await SharedPreferences.getInstance();
//     // Load cached data if available and valid
//     await _loadCachedProducts();
//   }

//   @override
//   void onClose() {
//     // Dispose all text controllers
//     stockControllers.forEach((_, controller) => controller.dispose());
//     super.onClose();
//   }

//   // Load cached products from SharedPreferences
//   Future<void> _loadCachedProducts() async {
//     final cachedData = _prefs.getString(_productsCacheKey);
//     final cacheTimestamp = _prefs.getInt(_cacheTimestampKey) ?? 0;

//     // Check if cache is valid (within 5 minutes)
//     if (cachedData != null &&
//         DateTime.now().millisecondsSinceEpoch - cacheTimestamp <
//             _cacheDuration) {
//       // Parse cached data
//       final List<dynamic> cachedProducts = jsonDecode(cachedData);
//       // Initialize stock controllers with cached data
//       for (var product in cachedProducts) {
//         final productId = product['id'] as String;
//         stockControllers[productId] = TextEditingController(
//           text: (product['stock'] ?? 0).toString(),
//         );
//       }
//     } else {
//       // Cache is invalid or empty, fetch from Firestore
//       await _fetchAndCacheProducts();
//     }
//   }

//   // Fetch products from Firestore and cache them
//   Future<void> _fetchAndCacheProducts() async {
//     try {
//       final snapshot = await products.get();
//       final List<Map<String, dynamic>> productList = snapshot.docs
//           .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
//           .toList();

//       // Cache the products
//       await _prefs.setString(_productsCacheKey, jsonEncode(productList));
//       await _prefs.setInt(
//         _cacheTimestampKey,
//         DateTime.now().millisecondsSinceEpoch,
//       );

//       // Initialize stock controllers
//       for (var product in productList) {
//         final productId = product['id'] as String;
//         stockControllers[productId] = TextEditingController(
//           text: (product['stock'] ?? 0).toString(),
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to fetch products: $e',
//         backgroundColor: const Color(0xFFE53E3E),
//         colorText: Colors.white,
//         icon: const Icon(Icons.error_outline, color: Colors.white),
//         snackPosition: SnackPosition.TOP,
//         borderRadius: 8,
//         margin: const EdgeInsets.all(16),
//       );
//     }
//   }

//   // Updates the stock value for a product in Firestore and the UI
//   Future<void> updateStock(String productId, int newStock) async {
//     // Prevent negative stock values
//     if (newStock < 0) {
//       Get.snackbar(
//         'Error',
//         'Stock cannot be negative',
//         backgroundColor: const Color(0xFFE53E3E),
//         colorText: Colors.white,
//         icon: const Icon(Icons.error_outline, color: Colors.white),
//         snackPosition: SnackPosition.TOP,
//         borderRadius: 8,
//         margin: const EdgeInsets.all(16),
//       );
//       return;
//     }

//     // Optimistically update the TextEditingController
//     stockControllers[productId]?.text = newStock.toString();

//     try {
//       // Update the stock field in Firestore
//       await products.doc(productId).update({'stock': newStock});
//       HapticFeedback.lightImpact();
//       // Refresh cache after updating stock
//       await _fetchAndCacheProducts();
//     } catch (e) {
//       // Revert the TextEditingController if the update fails
//       final doc = await products.doc(productId).get();
//       final currentStock = (doc.data() as Map<String, dynamic>?)?['stock'] ?? 0;
//       stockControllers[productId]?.text = currentStock.toString();
//       Get.snackbar(
//         'Error',
//         'Failed to update stock: $e',
//         backgroundColor: const Color(0xFFE53E3E),
//         colorText: Colors.white,
//         icon: const Icon(Icons.error_outline, color: Colors.white),
//         snackPosition: SnackPosition.TOP,
//         borderRadius: 8,
//         margin: const EdgeInsets.all(16),
//       );
//     }
//   }

//   // Increments the stock of a product by 1
//   Future<void> incrementStock(String productId, int currentStock) async {
//     await updateStock(productId, currentStock + 1);
//   }

//   // Decrements the stock of a product by 1
//   Future<void> decrementStock(String productId, int currentStock) async {
//     await updateStock(productId, currentStock - 1);
//   }

//   // Updates stock based on user input from text field
//   Future<void> editStock(String productId, String stockText) async {
//     final newStock = int.tryParse(stockText);
//     if (newStock == null) {
//       Get.snackbar(
//         'Error',
//         'Please enter a valid number',
//         backgroundColor: const Color(0xFFE53E3E),
//         colorText: Colors.white,
//         icon: const Icon(Icons.error_outline, color: Colors.white),
//         snackPosition: SnackPosition.TOP,
//         borderRadius: 8,
//         margin: const EdgeInsets.all(16),
//       );
//       return;
//     }
//     await updateStock(productId, newStock);
//   }

//   // Refresh products and cache
//   Future<void> refreshProducts() async {
//     searchQuery.value = '';
//     await _fetchAndCacheProducts();
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// GetX Controller for FreeStocks
class FreeStocksController extends GetxController {
  // Reference to the 'products' collection in Firestore
  final CollectionReference products = FirebaseFirestore.instance.collection(
    'products',
  );

  // Reactive map for TextEditingControllers
  final RxMap<String, TextEditingController> stockControllers =
      <String, TextEditingController>{}.obs;

  // Reactive search query
  final RxString searchQuery = ''.obs;

  // SharedPreferences instance
  late SharedPreferences _prefs;
  static const String _productsCacheKey = 'cached_products';
  static const String _cacheTimestampKey = 'cache_timestamp';
  static const int _cacheDuration = 5 * 60 * 1000; // Cache for 5 minutes

  @override
  void onInit() async {
    super.onInit();
    // Initialize SharedPreferences
    _prefs = await SharedPreferences.getInstance();
    // Load cached data if available and valid
    await _loadCachedProducts();
  }

  @override
  void onClose() {
    // Dispose all text controllers
    stockControllers.forEach((_, controller) => controller.dispose());
    super.onClose();
  }

  // Helper method to convert Firestore data to serializable format
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

  // Helper method to convert serializable data back to Firestore format
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

  // Load cached products from SharedPreferences
  Future<void> _loadCachedProducts() async {
    final cachedData = _prefs.getString(_productsCacheKey);
    final cacheTimestamp = _prefs.getInt(_cacheTimestampKey) ?? 0;

    // Check if cache is valid (within 5 minutes)
    if (cachedData != null &&
        DateTime.now().millisecondsSinceEpoch - cacheTimestamp <
            _cacheDuration) {
      try {
        // Parse cached data
        final List<dynamic> cachedProducts = jsonDecode(cachedData);
        // Initialize stock controllers with cached data
        for (var product in cachedProducts) {
          final productId = product['id'] as String;
          stockControllers[productId] = TextEditingController(
            text: (product['stock'] ?? 0).toString(),
          );
        }
      } catch (e) {
        // If cache is corrupted, fetch from Firestore
        await _fetchAndCacheProducts();
      }
    } else {
      // Cache is invalid or empty, fetch from Firestore
      await _fetchAndCacheProducts();
    }
  }

  // Fetch products from Firestore and cache them
  Future<void> _fetchAndCacheProducts() async {
    try {
      final snapshot = await products.get();
      final List<Map<String, dynamic>> productList = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final convertedData = _convertFirestoreData(data);
        productList.add({'id': doc.id, ...convertedData});
      }

      // Cache the products
      await _prefs.setString(_productsCacheKey, jsonEncode(productList));
      await _prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      // Initialize stock controllers
      for (var product in productList) {
        final productId = product['id'] as String;
        stockControllers[productId] = TextEditingController(
          text: (product['stock'] ?? 0).toString(),
        );
      }
    } catch (e) {
      _showErrorSnackbar('Failed to fetch products: $e');
    }
  }

  // Updates the stock value for a product in Firestore and the UI
  Future<void> updateStock(String productId, int newStock) async {
    // Prevent negative stock values
    if (newStock < 0) {
      _showErrorSnackbar('Stock cannot be negative');
      return;
    }

    // Optimistically update the TextEditingController
    stockControllers[productId]?.text = newStock.toString();

    try {
      // Update the stock field in Firestore
      await products.doc(productId).update({'stock': newStock});
      HapticFeedback.lightImpact();
      
      // Show success feedback
      _showSuccessSnackbar('Stock updated successfully');
      
      // Refresh cache after updating stock
      await _fetchAndCacheProducts();
    } catch (e) {
      // Revert the TextEditingController if the update fails
      final doc = await products.doc(productId).get();
      final currentStock = (doc.data() as Map<String, dynamic>?)?['stock'] ?? 0;
      stockControllers[productId]?.text = currentStock.toString();
      _showErrorSnackbar('Failed to update stock: $e');
    }
  }

  // Increments the stock of a product by 1
  Future<void> incrementStock(String productId, int currentStock) async {
    await updateStock(productId, currentStock + 1);
  }

  // Decrements the stock of a product by 1
  Future<void> decrementStock(String productId, int currentStock) async {
    await updateStock(productId, currentStock - 1);
  }

  // Updates stock based on user input from text field
  Future<void> editStock(String productId, String stockText) async {
    final newStock = int.tryParse(stockText);
    if (newStock == null) {
      _showErrorSnackbar('Please enter a valid number');
      return;
    }
    await updateStock(productId, newStock);
  }

  // Refresh products and cache
  Future<void> refreshProducts() async {
    searchQuery.value = '';
    await _fetchAndCacheProducts();
  }

  // Helper method to show error snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
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

  // Helper method to show success snackbar
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
}