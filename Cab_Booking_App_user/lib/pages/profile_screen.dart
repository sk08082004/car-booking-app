import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:user_app/global/global_var.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();

  final DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");

  Future<void> showUserDialogAlert({
    required BuildContext context,
    required String title,
    required TextEditingController controller,
    required String fieldKey,
    required String currentValue,
  }) async {
    controller.text = currentValue;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextFormField(
            controller: controller,
            decoration: InputDecoration(labelText: "Enter new $title"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                userRef.child(firebaseAuth.currentUser!.uid).update({
                  fieldKey: controller.text.trim(),
                }).then((value) {
                  Fluttertoast.showToast(msg: "$title updated successfully. Reload the app to see changes.");
                  setState(() {});
                  Navigator.pop(context);
                }).catchError((errorMessage) {
                  Fluttertoast.showToast(msg: "Error occurred: $errorMessage");
                });
              },
              child: const Text("Save", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          backgroundColor: darkTheme ? Colors.black : Colors.blue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 50,
                  backgroundColor: darkTheme ? Colors.amber : Colors.blue,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),

                // Name
                buildEditableField(
                  context,
                  title: "Name",
                  value: userModelCurrentInfo?.name ?? "N/A",
                  onEdit: () => showUserDialogAlert(
                    context: context,
                    title: "Name",
                    controller: nameTextEditingController,
                    fieldKey: "name",
                    currentValue: userModelCurrentInfo?.name ?? "",
                  ),
                ),

                // Phone
                buildEditableField(
                  context,
                  title: "Phone",
                  value: userModelCurrentInfo?.phone ?? "N/A",
                  onEdit: () => showUserDialogAlert(
                    context: context,
                    title: "Phone",
                    controller: phoneTextEditingController,
                    fieldKey: "phone",
                    currentValue: userModelCurrentInfo?.phone ?? "",
                  ),
                ),

                // Address
                buildEditableField(
                  context,
                  title: "Address",
                  value: userModelCurrentInfo?.address ?? "N/A",
                  onEdit: () => showUserDialogAlert(
                    context: context,
                    title: "Address",
                    controller: addressTextEditingController,
                    fieldKey: "address",
                    currentValue: userModelCurrentInfo?.address ?? "",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEditableField(BuildContext context,
      {required String title, required String value, required VoidCallback onEdit}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$title: $value",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
          ],
        ),
        const Divider(thickness: 1),
      ],
    );
  }
}
