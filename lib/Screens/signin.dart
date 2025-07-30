// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import 'package:makers/Controller/Auth_Controller/sign_in_controller.dart';
// import 'package:makers/Screens/forgotui.dart';
// import 'package:makers/Screens/home.dart';

// class Signin extends StatelessWidget {
//   final controller = Get.put(SigninController());

//   Signin({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 SizedBox(height: 98),
//                 // Logo section
//                 Container(
//                   height: 80,
//                   margin: const EdgeInsets.only(bottom: 48),
//                   child: Image.asset(
//                     'assets/images/logo.png',
//                     fit: BoxFit.contain,
//                   ),
//                 ),

//                 // Welcome text
//                 Text(
//                   "Welcome Back",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF9B0062),
//                     letterSpacing: -0.5,
//                   ),
//                 ),

//                 Text(
//                   "Sign in to continue",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),

//                 const SizedBox(height: 48),

//                 // Email/Phone field
//                 TextField(
//                   controller: controller.emailOrPhoneController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: InputDecoration(
//                     labelText: "Email or Phone",
//                     labelStyle: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 16,
//                     ),
//                     prefixIcon: Icon(
//                       Icons.person_outline,
//                       color: Color(0xFF9B0062),
//                       size: 20,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.grey[300]!),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.grey[300]!),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(
//                         color: Color(0xFF9B0062),
//                         width: 2,
//                       ),
//                     ),
//                     filled: true,
//                     fillColor: Colors.grey[50],
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 16,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Password field
//                 Obx(
//                   () => TextField(
//                     controller: controller.passwordController,
//                     obscureText: !controller.isPasswordVisible.value,
//                     decoration: InputDecoration(
//                       labelText: "Password",
//                       labelStyle: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 16,
//                       ),
//                       prefixIcon: Icon(
//                         Icons.lock_outline,
//                         color: Color(0xFF9B0062),
//                         size: 20,
//                       ),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           controller.isPasswordVisible.value
//                               ? Icons.visibility_outlined
//                               : Icons.visibility_off_outlined,
//                           color: Colors.grey[600],
//                           size: 20,
//                         ),
//                         onPressed: controller.togglePasswordVisibility,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.grey[300]!),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.grey[300]!),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(
//                           color: Color(0xFF9B0062),
//                           width: 2,
//                         ),
//                       ),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 16,
//                       ),
//                     ),
//                   ),
//                 ),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     SizedBox(
//                       child: TextButton(
//                         onPressed: () {
//                           Get.to(() => ForgotPasswordPage());
//                         },
//                         child: Text(
//                           'Forgot Password?',
//                           style: TextStyle(
//                             color: const Color.fromARGB(255, 28, 70, 169),
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 35),
//                 // Sign in button
//                 SizedBox(
//                   height: 52,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFF9B0062),
//                       foregroundColor: Colors.white,
//                       elevation: 0,
//                       shadowColor: Colors.transparent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     onPressed: () async {
//                       final input = controller.emailOrPhoneController.text
//                           .trim();
//                       final password = controller.passwordController.text
//                           .trim();

//                       if (input.isEmpty || password.isEmpty) {
//                         Get.snackbar(
//                           "Error",
//                           "Please fill in both fields",
//                           backgroundColor: Colors.red[50],
//                           colorText: Colors.red[700],
//                           borderRadius: 8,
//                           margin: const EdgeInsets.all(16),
//                         );
//                         return;
//                       }

//                       Get.dialog(
//                         Center(
//                           child: CircularProgressIndicator(
//                             color: Color(0xFF9B0062),
//                           ),
//                         ),
//                         barrierDismissible: false,
//                       );

//                       final result = await controller.signIn(input, password);
//                       Get.back();

//                       if (result == null) {
//                         controller.emailOrPhoneController.clear();
//                         controller.passwordController.clear();

//                         Get.offAll(() => Dashboard());
//                         Get.snackbar(
//                           "Success",
//                           "Signed in successfully",
//                           backgroundColor: Colors.green[50],
//                           colorText: Colors.green[700],
//                           borderRadius: 8,
//                           margin: const EdgeInsets.all(16),
//                         );
//                       } else {
//                         Get.snackbar(
//                           "Login Failed",
//                           "Please enter valid credentials",
//                           backgroundColor: Colors.red[50],
//                           colorText: Colors.red[700],
//                           borderRadius: 8,
//                           margin: const EdgeInsets.all(16),
//                         );
//                       }
//                     },
//                     child: Text(
//                       "Sign In",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 24),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:makers/Controller/Auth_Controller/sign_in_controller.dart';
import 'package:makers/Screens/forgotui.dart';
import 'package:makers/Screens/home.dart';

class Signin extends StatelessWidget {
  final SigninController controller = Get.put(SigninController());

  Signin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 98),
                // Logo section
                Container(
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 48),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),

                // Welcome text
                const Text(
                  "Welcome Back",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9B0062),
                    letterSpacing: -0.5,
                  ),
                ),

                Text(
                  "Sign in to continue",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 48),

                // Email/Phone field
                TextField(
                  controller: controller.emailOrPhoneController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email or Phone",
                    labelStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF9B0062),
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF9B0062),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Password field
                Obx(
                  () => TextField(
                    controller: controller.passwordController,
                    obscureText: !controller.isPasswordVisible.value,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF9B0062),
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF9B0062),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      child: TextButton(
                        onPressed: () {
                          Get.to(() => ForgotPasswordPage());
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Color.fromARGB(255, 28, 70, 169),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                // Sign in button
                SizedBox(
                  height: 52,
                  // Obx rebuilds only the parts that depend on reactive variables
                  child: Obx(
                    () => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9B0062),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      // Disable the button when isLoading is true
                      onPressed: controller.isLoading.value
                          ? null // 'null' disables the button
                          : () async {
                              final input = controller
                                  .emailOrPhoneController
                                  .text
                                  .trim();
                              final password = controller
                                  .passwordController
                                  .text
                                  .trim();

                              if (input.isEmpty || password.isEmpty) {
                                Get.snackbar(
                                  "Oops!",
                                  "Please fill in both fields",
                                  backgroundColor: Colors.red[50],
                                  colorText: Colors.red[700],
                                  borderRadius: 8,
                                  margin: const EdgeInsets.all(16),
                                );
                                return;
                              }

                              // No Get.dialog here, as the loader is in the button.
                              final result = await controller.signIn(
                                input,
                                password,
                              );

                              if (result == null) {
                                controller.clearFields();
                                Get.offAll(() => Dashboard());
                                Get.snackbar(
                                  "Success",
                                  "Signed in successfully",
                                  backgroundColor: Colors.green[50],
                                  colorText: Colors.green[700],
                                  borderRadius: 8,
                                  margin: const EdgeInsets.all(16),
                                );
                              } else {
                                Get.snackbar(
                                  "Login Failed",
                                  result, // Display the specific error message
                                  backgroundColor: Colors.red[50],
                                  colorText: Colors.red[700],
                                  borderRadius: 8,
                                  margin: const EdgeInsets.all(16),
                                );
                              }
                            },
                      // Conditional child based on isLoading state
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 24, // Fixed width for the spinner
                              height: 24, // Fixed height for the spinner
                              child: CircularProgressIndicator(
                                color: Colors.white, // Spinner color
                                strokeWidth: 3, // Thickness of the spinner
                              ),
                            )
                          : const Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
