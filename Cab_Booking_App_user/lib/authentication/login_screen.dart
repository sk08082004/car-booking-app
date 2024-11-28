import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:user_app/authentication/signup_screen.dart';
import 'package:user_app/methods/common_methods.dart';
import 'package:user_app/pages/home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailTextEditingController = TextEditingController();
  final TextEditingController passwordTextEditingController = TextEditingController();
  final CommonMethods cMethods = CommonMethods();

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(color: Colors.yellow),
              const SizedBox(width: 20),
              Expanded(child: Text(message)),
            ],
          ),
        );
      },
    );
  }

  Future<void> _signInUser() async {
    try {
      // Show loading dialog
      _showLoadingDialog("Allowing you to log in...");

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      );

      User? userFirebase = userCredential.user;
      if (userFirebase != null) {
        DatabaseReference userRef =
            FirebaseDatabase.instance.ref().child("users").child(userFirebase.uid);

        DatabaseEvent event = await userRef.once();
        if (event.snapshot.value != null) {
          Map userData = event.snapshot.value as Map;

          if (userData["blockStatus"] == "no") {
            String userName = userData["name"];
            Navigator.pop(context); // Close loading dialog
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
            cMethods.displaySnackBar("Welcome, $userName!", context, isSuccess: true);
          } else {
            FirebaseAuth.instance.signOut();
            Navigator.pop(context);
            cMethods.displaySnackBar("You are blocked. Contact admin.", context);
          }
        } else {
          FirebaseAuth.instance.signOut();
          Navigator.pop(context);
          cMethods.displaySnackBar("Your record does not exist.", context);
        }
      }
    } catch (error) {
      Navigator.pop(context); // Close loading dialog
      cMethods.displaySnackBar(error.toString(), context);
    }
  }

  void _validateAndLogin() {
    String email = emailTextEditingController.text.trim();
    String password = passwordTextEditingController.text.trim();

    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      cMethods.displaySnackBar("Enter a valid email address!", context);
      return;
    }

    if (password.isEmpty || password.length < 6) {
      cMethods.displaySnackBar("Password must be at least 6 characters long!", context);
      return;
    }

    _signInUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 70),
              // Logo Section with Padding
              const Icon(
                Icons.local_taxi,
                size: 120.0,
                color: Color(0xFFFFC828),
              ),
              const SizedBox(height: 20),

              // Title with Better Spacing and Styling
              const Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 28,
                  color: Color(0xFF002137),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Log in to continue to your account.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Input Fields with New Design
              _buildTextField(
                controller: emailTextEditingController,
                labelText: "Email Address",
                icon: Icons.email,
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: passwordTextEditingController,
                labelText: "Password",
                icon: Icons.lock,
                inputType: TextInputType.text,
                obscureText: true,
              ),
              const SizedBox(height: 15),

              // Forgot Password Text with Padding
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // TODO: Implement Forgot Password functionality
                    print("Forgot Password tapped");
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Color(0xFFFFC828),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Login Button with New Styling
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC828),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: Colors.black,
                    elevation: 5,
                  ),
                  onPressed: _validateAndLogin,
                  child: const Text(
                    "Log In",
                    style: TextStyle(
                      color: Color(0xFF002137),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Footer with Padding
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Color(0xFFFFC828),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom TextField widget with improved design
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFFFFC828)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFFFC828),
            width: 2,
          ),
        ),
      ),
    );
  }
}
