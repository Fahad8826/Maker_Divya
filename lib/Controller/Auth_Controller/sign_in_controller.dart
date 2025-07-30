// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class SigninController extends GetxController {
//   final emailOrPhoneController = TextEditingController();
//   final passwordController = TextEditingController();

//   var isPasswordVisible = false.obs;
//   var isInputEmpty = true.obs;
//   var isInputValid = false.obs;

//   @override
//   void onInit() {
//     super.onInit();

//     emailOrPhoneController.addListener(() {
//       final input = emailOrPhoneController.text.trim();
//       isInputEmpty.value = input.isEmpty;
//       isInputValid.value = _isValidEmail(input) || _isValidPhone(input);
//     });
//   }

//   bool _isValidEmail(String email) {
//     final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//     return emailRegex.hasMatch(email);
//   }

//   bool _isValidPhone(String phone) {
//     final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
//     return phoneRegex.hasMatch(phone);
//   }

//   Future<String?> getEmailFromPhone(String phone) async {
//     try {
//       final query = await FirebaseFirestore.instance
//           .collection('users')
//           .where('phone', isEqualTo: phone)
//           .limit(1)
//           .get();
//       if (query.docs.isNotEmpty) {
//         return query.docs.first.get('email');
//       }
//     } catch (_) {}
//     return null;
//   }

//   Future<String?> signIn(String input, String password) async {
//     try {
//       String? email;
//       String? uid;

//       if (_isValidEmail(input)) {
//         email = input;
//       } else if (_isValidPhone(input)) {
//         final query = await FirebaseFirestore.instance
//             .collection('users')
//             .where('phone', isEqualTo: input)
//             .limit(1)
//             .get();
//         if (query.docs.isNotEmpty) {
//           email = query.docs.first.get('email');
//           uid = query.docs.first.get('uid');
//         } else {
//           return 'No account found for this phone number.';
//         }
//       } else {
//         return 'Invalid email or phone number format.';
//       }

//       final userCredential = await FirebaseAuth.instance
//           .signInWithEmailAndPassword(email: email!, password: password);

//       uid ??= userCredential.user?.uid;

//       final usersDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(uid)
//           .get();

//       if (!usersDoc.exists) {
//         await FirebaseAuth.instance.signOut();
//         return 'Access denied. User does not exist.';
//       }

//       if (usersDoc['role'] != 'maker') {
//         await FirebaseAuth.instance.signOut();
//         return 'Access denied. You are not a Maker.';
//       }

//       if (usersDoc['isActive'] != true) {
//         await FirebaseAuth.instance.signOut();
//         return 'Access denied. You are Disabled.';
//       }

//       return null;
//     } on FirebaseAuthException catch (e) {
//       return e.message;
//     } catch (e) {
//       return 'Unexpected error: $e';
//     }
//   }

//   void togglePasswordVisibility() {
//     isPasswordVisible.value = !isPasswordVisible.value;
//   }

//   void clearFields() {
//     emailOrPhoneController.clear();
//     passwordController.clear();
//   }

//   @override
//   void onClose() {
//     emailOrPhoneController.dispose();
//     passwordController.dispose();
//     super.onClose();
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SigninController extends GetxController {
  final emailOrPhoneController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordVisible = false.obs;
  var isInputEmpty = true.obs;
  var isInputValid = false.obs;
  var isLoading = false.obs; // <--- NEW: Reactive variable for loading state

  @override
  void onInit() {
    super.onInit();

    emailOrPhoneController.addListener(() {
      final input = emailOrPhoneController.text.trim();
      isInputEmpty.value = input.isEmpty;
      isInputValid.value = _isValidEmail(input) || _isValidPhone(input);
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    // A more robust phone regex that allows for optional '+' and a minimum of 10 digits
    // and can handle spaces/dashes, but primarily focuses on digit count for validation.
    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    return phoneRegex.hasMatch(
      phone.replaceAll(RegExp(r'[\s-]'), ''),
    ); // Remove spaces/dashes for validation
  }

  // This method is already in your controller, but putting it here for completeness
  Future<String?> getEmailFromPhone(String phone) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return query.docs.first.get('email');
      }
    } catch (_) {
      // Handle or log error if necessary
    }
    return null;
  }

  Future<String?> signIn(String input, String password) async {
    // Prevent multiple sign-in attempts if already loading
    if (isLoading.value) {
      return null; // Or return a specific message like "Already signing in..."
    }

    isLoading.value = true; // Set loading state to true
    String? errorMessage;

    try {
      String? emailToSignIn;
      String? uid; // To potentially store UID if found via phone number

      if (_isValidEmail(input)) {
        emailToSignIn = input;
      } else if (_isValidPhone(input)) {
        final query = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: input)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          emailToSignIn = query.docs.first.get('email');
          uid = query.docs.first.id; // Get the document ID as UID
        } else {
          errorMessage = 'No account found for this phone number.';
        }
      } else {
        errorMessage = 'Invalid email or phone number format.';
      }

      // If there's an error message from initial validation, return it early
      if (errorMessage != null) {
        return errorMessage;
      }

      // Proceed with Firebase authentication only if emailToSignIn is not null
      if (emailToSignIn != null) {
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: emailToSignIn,
              password: password,
            );

        // If UID was not found via phone lookup, get it from the UserCredential
        uid ??= userCredential.user?.uid;

        if (uid == null) {
          // This case should ideally not happen if signInWithEmailAndPassword succeeds,
          // but as a fallback.
          await FirebaseAuth.instance.signOut();
          return 'Authentication successful, but user data not found. Please try again.';
        }

        final usersDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (!usersDoc.exists) {
          await FirebaseAuth.instance.signOut();
          return 'Access denied. User data missing.';
        }

        // Use safe access with `[]` if you are sure the field exists, or `.data()` with null check
        if (usersDoc.data()?['role'] != 'maker') {
          await FirebaseAuth.instance.signOut();
          return 'Access denied. You are not a Maker.';
        }

        if (usersDoc.data()?['isActive'] != true) {
          await FirebaseAuth.instance.signOut();
          return 'Access denied. Your account is disabled.';
        }

        // If everything is successful, return null to indicate no error
        return null;
      } else {
        // This should be covered by earlier checks, but as a safeguard
        return 'Could not determine login method.';
      }
    } on FirebaseAuthException catch (e) {
      // Provide more user-friendly messages for common errors
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        errorMessage = 'Invalid email/phone or password.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not validly formatted.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'Your account has been disabled.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'No internet connection. Please try again.';
      } else {
        errorMessage = 'Authentication error: ${e.message}';
      }
      return errorMessage;
    } catch (e) {
      errorMessage = 'An unexpected error occurred: $e';
      return errorMessage;
    } finally {
      // Ensure loading state is reset regardless of success or failure
      isLoading.value = false;
      // It's generally better to handle Get.back() from the UI,
      // but if you must handle it here, ensure it's conditional.
      // For a loading dialog, typically the UI widget itself dismisses it based on isLoading.value becoming false.
      // If you are showing a Get.dialog, ensure it's dismissed here
      if (Get.isDialogOpen!) {
        Get.back();
      }
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void clearFields() {
    emailOrPhoneController.clear();
    passwordController.clear();
  }

  @override
  void onClose() {
    emailOrPhoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
