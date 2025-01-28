import 'package:flutter/material.dart';
import 'package:ordering_system/auth/authcontroller.dart';
import 'package:ordering_system/dialog/dialog.dart';
import 'package:ordering_system/firebase/services.dart';
import 'package:ordering_system/model/user.dart';
import 'package:ordering_system/util/app_style.dart';
import 'package:ordering_system/util/size_config.dart';
import 'package:provider/provider.dart';

class AdminRegisterScreen extends StatefulWidget {
  static const String route = '/adminregister';

  static const String name = 'AdminRegisterScreen';
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<FirebaseServices>(context, listen: false).fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("App Users", style: mRegular.copyWith(color: mBlack, fontSize: 23, letterSpacing: 2)),
        leading: IconButton(
          onPressed: () {
            Provider.of<FirebaseServices>(context, listen: false).fetchUsers();
          },
          icon: const Icon(Icons.refresh),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showNewPostFunction(context);
            },
            icon: const Icon(Icons.add, color: mOrange),
          ),
          IconButton(
            onPressed: (){
              WaitingDialog.show(context, future: AuthController.I.logout());
            },
            icon: const Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<FirebaseServices>(
          builder: (context, userProvider, _) {
            if (userProvider.users.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return ListView.builder(
                itemCount: userProvider.users.length,
                itemBuilder: (context, index) {
                  User user = userProvider.users[index];
                  return Card(
                    elevation: 4,
                    child: ListTile(
                      title:  Text('${user.firstName} ${user.lastName}', style: mRegular.copyWith(color: mBlack, fontSize: 16),),
                      subtitle: Text('role: ${user.role}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              editUser(context, user);
                            },
                            icon: const Icon(Icons.edit),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
  void showNewPostFunction(BuildContext context) {
    AddUserDialog.show(
      context,
      controller: Provider.of<FirebaseServices>(context, listen: false),
    );
  }

  void editUser(BuildContext context, User user) async{
    final updatedPost = await EditUser.show(
      context,
      userRole: user,
      controller: Provider.of<FirebaseServices>(context, listen: false),
    );
  }
}

class AddUserDialog extends StatefulWidget {
  static void show(BuildContext context, {required FirebaseServices controller}) {
    showDialog(
      context: context,
      builder: (dContext) => AddUserDialog(controller),
    );
  }

  const AddUserDialog(this.controller, {super.key});

  final FirebaseServices controller;

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  late TextEditingController firstNameController, lastNameController, emailController, passwordController;
  String selectedRole = 'Customer';
  bool isVisible = false;
  bool isObscure = true;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  Future<void> _addUser() async {
    try {
      await widget.controller.addUser(
        firstNameController.text.trim(),
        lastNameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
        selectedRole,
      );
      Navigator.of(context).pop();
    } catch (e) {
      print('Error adding user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add user. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: Text(
        "Add new user",
       style: mMedium.copyWith(color: mBlack, fontSize: 20),
      ),
      actions: [
        ElevatedButton(
          onPressed: _addUser,
          child: Text("Submit", style: mRegular.copyWith(color: mBlack, fontSize: 14),),
        )
      ],
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: "First Name"),
            ),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: "Last Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isObscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isObscure = !isObscure;
                          });
                        },
                      ),
                    ),
                    obscureText: isObscure,
                  ),
            const SizedBox(height: 25,),
            DropdownButtonFormField<String>(
              value: selectedRole,
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
              },
              items: <String>['Customer', 'Admin', 'Kitchen', 'Cashier'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

class EditUser extends StatefulWidget {
  static show(BuildContext context, {required User userRole, required FirebaseServices controller}) =>
      showDialog(
        context: context,
        builder: (dContext) => EditUser(userRole, controller),
      );

  final User userRole;
  final FirebaseServices controller;

  const EditUser(this.userRole, this.controller, {super.key});

  @override
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  late String selectedRole;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.userRole.role;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: Text(
        "Edit User's Rol",
        style: mMedium.copyWith(color: mBlack, fontSize: 20),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            await widget.controller.editUser(
              widget.userRole,
              selectedRole,
            );
            Navigator.of(context).pop();
          },
          child: Text("Submit", style: mRegular.copyWith(color: mBlack, fontSize: 14)),
        )
      ],
      content: SingleChildScrollView(
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedRole,
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
              },
              items: <String>['Customer', 'Admin', 'Kitchen', 'Cashier'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}