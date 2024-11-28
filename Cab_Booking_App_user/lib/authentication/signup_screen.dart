import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:user_app/authentication/login_screen.dart';
import 'package:user_app/methods/common_methods.dart';
import 'package:user_app/pages/home_page.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController userNameTextEditingController =
      TextEditingController();
  final TextEditingController userPhoneTextEditingController =
      TextEditingController();
  final TextEditingController emailTextEditingController =
      TextEditingController();
  final TextEditingController passwordTextEditingController =
      TextEditingController();
  final TextEditingController addressTextEditingController =
      TextEditingController();  // New address controller

  final CommonMethods cMethods = CommonMethods();

  Future<void> _validateAndSubmit() async {
    final String username = userNameTextEditingController.text.trim();
    final String phone = userPhoneTextEditingController.text.trim();
    final String email = emailTextEditingController.text.trim();
    final String password = passwordTextEditingController.text.trim();
    final String address = addressTextEditingController.text.trim(); // Address input

    if (username.isEmpty) {
      _showSnackBar("Username cannot be empty!");
      return;
    }

    if (phone.isEmpty ||
        phone.length != 10 ||
        !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      _showSnackBar("Enter a valid 10-digit phone number!");
      return;
    }

    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showSnackBar("Enter a valid email address!");
      return;
    }

    if (password.isEmpty || password.length < 6) {
      _showSnackBar("Password must be at least 6 characters long!");
      return;
    }

    if (address.isEmpty) {
      _showSnackBar("Address cannot be empty!");
      return;
    }

    bool isConnected = await cMethods.checkConnectivity(context);
    if (!isConnected) return;

    _showLoadingDialog("Registering your account...");
    await registerNewUser(username, phone, email, password, address);
  }

  Future<void> registerNewUser(
      String username, String phone, String email, String password, String address) async {
    try {
      final User? userFirebase = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((userCredential) => userCredential.user);

      if (userFirebase == null) {
        throw "User registration failed. Please try again.";
      }

      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child("users").child(userFirebase.uid);

      Map<String, String> userDataMap = {
        "name": username,
        "phone": phone,
        "email": email,
        "id": userFirebase.uid,
        "blockStatus": "no",
        "address": address,  // Save the address
      };

      await userRef.set(userDataMap).catchError((error) {
        throw "Error saving user data: ${error.toString()}";
      });

      if (!mounted) return; // Ensure widget is still active

      Navigator.pop(context); // Close the loading dialog
      _showSnackBar("Registration successful!", success: true);

      // Clear input fields
      userNameTextEditingController.clear();
      userPhoneTextEditingController.clear();
      emailTextEditingController.clear();
      passwordTextEditingController.clear();
      addressTextEditingController.clear(); // Clear address field

      // Navigate to home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      Navigator.pop(context); // Close the loading dialog if open
      _showSnackBar("Error: $e");
    }
  }

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

  void _showSnackBar(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
              const SizedBox(height: 20),
              const Icon(
                Icons.local_taxi,
                size: 120.0,
                color: Color(0xFFFFC828),
              ),
              const SizedBox(height: 12),
              const Text(
                "Create Your Account",
                style: TextStyle(
                  fontSize: 28,
                  color: Color(0xFF002137),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Sign up to get started with our services",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: userNameTextEditingController,
                      labelText: "Username",
                      icon: Icons.person,
                      inputType: TextInputType.text,
                      borderColor: const Color(0xFFFFC828),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: userPhoneTextEditingController,
                      labelText: "Phone Number",
                      icon: Icons.phone,
                      inputType: TextInputType.phone,
                      borderColor: const Color(0xFFFFC828),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: emailTextEditingController,
                      labelText: "Email Address",
                      icon: Icons.email,
                      inputType: TextInputType.emailAddress,
                      borderColor: const Color(0xFFFFC828),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: passwordTextEditingController,
                      labelText: "Password",
                      icon: Icons.lock,
                      inputType: TextInputType.visiblePassword,
                      obscureText: true,
                      borderColor: const Color(0xFFFFC828),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: addressTextEditingController,  // New address field
                      labelText: "Address",
                      icon: Icons.home,
                      inputType: TextInputType.streetAddress,
                      borderColor: const Color(0xFFFFC828),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC828),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  onPressed: _validateAndSubmit,
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Color(0xFF002137),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Login",
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool obscureText = false,
    required Color borderColor,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFFFFC828)),
        prefixIcon: Icon(icon, color: const Color(0xFFFFC828)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
