import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:makers/Controller/forgot_controller.dart';
import 'package:makers/Screens/signin.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    PasswordController controller = Get.put(PasswordController());
    return PopScope(
      onPopInvoked: (didPop) {
        if (!didPop) {
          Get.off(() => Signin());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Get.off(() => Signin());
            },
            icon: Icon(Icons.arrow_back),
          ),
          title: Text(
            'Forgot Password',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF9B0062),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter your email address to receive a password reset link.",
                  // style: GoogleFonts.oswald(
                  //   fontSize: MediaQuery.of(context).size.height * 0.02,
                  // ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller.emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.black54, fontSize: 16),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 5, 5, 5),
                        width: 2,
                      ), 
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Email is required";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.formKey.currentState!.validate()) {
                        controller.sendResetEmail();
                        controller.emailController.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF9B0062),
                    ),
                    child: Text(
                      'Send Reset Email',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
