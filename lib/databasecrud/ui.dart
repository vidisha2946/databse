import 'package:flutter/material.dart';
import 'databse.dart'; // Ensure this import points to your DatabaseHelper class

void main() {
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  List<Map<String, dynamic>> users = [];
  int? selectedUserId;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    final data = await DatabaseHelper.instance.fetchUsers();
    setState(() {
      users = data;
    });
  }
  Future<void> addOrUpdateUser() async {
    final name = nameController.text.trim();
    final city = cityController.text.trim();
    final email = emailController.text.trim();

    if (name.isNotEmpty && city.isNotEmpty && email.isNotEmpty) {
      if (selectedUserId == null) {
        await DatabaseHelper.instance.insertUser(name, city, email: email);
      } else {
        await DatabaseHelper.instance.updateUser(selectedUserId!, name, city, email: email);
        selectedUserId = null;
      }
      nameController.clear();
      cityController.clear();
      emailController.clear();
      // Reload users
      loadUsers();
    }
  }
  void editUser(int id, String currentName, String currentCity, String currentEmail) {
    setState(() {
      selectedUserId = id;
      nameController.text = currentName;
      cityController.text = currentCity;
      emailController.text = currentEmail;
    });
  }

  Future<void> deleteUser(int id) async {
    await DatabaseHelper.instance.deleteUser(id);
    loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("CRUD Database")),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
                  TextField(controller: cityController, decoration: InputDecoration(labelText: "City")),
                  TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")), // New email field
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: addOrUpdateUser,
                    child: Text(selectedUserId == null ? "Add User" : "Save"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    title: Text(user['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user['city']),
                        Text(user['email'] ?? 'No email'), // Display email
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => editUser(user['id'], user['name'], user['city'], user['email'] ?? ''),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteUser(user['id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}