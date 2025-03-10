import 'package:flutter/material.dart';
import 'databasecrud/databse.dart';
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

    if (name.isNotEmpty && city.isNotEmpty ) {
      if (selectedUserId == null) {
        await DatabaseHelper.instance.insertUser(name, city);
      } else
      {
        await DatabaseHelper.instance.updateUser(selectedUserId!, name, city);
        selectedUserId = null;
      }
      nameController.clear();
      cityController.clear();
      loadUsers();
    }
  }

  void editUser(int id, String currentName, String currentCity) {
    setState(() {
      selectedUserId = id;
      nameController.text = currentName;
      cityController.text = currentCity;
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
        appBar: AppBar(title: Text("CRUD DataBase")),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
                  TextField(controller: cityController, decoration: InputDecoration(labelText: "City")),
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
                    subtitle: Text(user['city']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => editUser(user['id'], user['name'], user['city']),
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
