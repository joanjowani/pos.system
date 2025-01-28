import 'package:flutter/material.dart';
import 'package:ordering_system/auth/authcontroller.dart';
import 'package:ordering_system/dialog/dialog.dart';
import 'package:ordering_system/firebase/services.dart';
import 'package:ordering_system/model/menu.dart';
import 'package:ordering_system/util/app_style.dart';
import 'package:ordering_system/util/size_config.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AdminMenuScreen extends StatefulWidget {
  static const String route = '/adminmenu';
  static const String name = 'AdminMenuScreen';

  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<FirebaseServices>(context, listen: false).fetchMenuItems();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu", style: mRegular.copyWith(color: mBlack, fontSize: 23, letterSpacing: 2)),
        leading: IconButton(
          onPressed: () {
            Provider.of<FirebaseServices>(context, listen: false).fetchMenuItems();
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
          builder: (context, menuProvider, _) {
            if (menuProvider.menuItems.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return ListView.builder(
                itemCount: menuProvider.menuItems.length,
                itemBuilder: (context, index) {
                  MenuItem menuItem = menuProvider.menuItems[index];
                  return Card(
                    elevation: 4,
                    child: ListTile(
                      leading: Image.network(menuItem.imageUrl),
                      title: Text(menuItem.name, style: mRegular.copyWith(color: mBlack, fontSize: 16),),
                      subtitle: Text('${menuItem.type} - P${menuItem.price.toStringAsFixed(2)}', style: mRegular.copyWith(color: mGrey, fontSize: 14)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              editMenuItem(context, menuItem);
                            },
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              deleteMenuItem(context, menuItem.id);
                            },
                            icon: const Icon(Icons.delete),
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
    AddPostDialog.show(
      context,
      controller: Provider.of<FirebaseServices>(context, listen: false),
    );
  }

  void editMenuItem(BuildContext context, MenuItem menuItem) async{
     await EditMenu.show(
      context,
      menu: menuItem,
      controller: Provider.of<FirebaseServices>(context, listen: false),
    );
  }

  void deleteMenuItem(BuildContext context, String menuItemId) async {
    try {
      await Provider.of<FirebaseServices>(context, listen: false).deleteMenuItem(menuItemId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu item deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete menu item')),
      );
    }
  }
}

class AddPostDialog extends StatefulWidget {
  static show(BuildContext context, {required FirebaseServices controller}) =>
      showDialog(
        context: context,
        builder: (dContext) => AddPostDialog(controller),
      );

  const AddPostDialog(this.controller, {super.key});

  final FirebaseServices controller;

  @override
  State<AddPostDialog> createState() => _AddPostDialogState();
}

class _AddPostDialogState extends State<AddPostDialog> {
  late TextEditingController typeController, nameController, priceController;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    typeController = TextEditingController();
    nameController = TextEditingController();
    priceController = TextEditingController();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: Text(
        "Add new menu",
        style: mMedium.copyWith(color: mBlack, fontSize: 20),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (imageFile != null) {
              await widget.controller.addMenuItem(
                typeController.text.trim(),
                nameController.text.trim(),
                double.parse(priceController.text.trim()),
                imageFile!.path,
              );
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select an image')),
              );
            }
          },
          child: Text("Submit", style: mRegular.copyWith(color: mBlack, fontSize: 14)),
        )
      ],
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: "Type"),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Pick Image"),
            ),
            if (imageFile != null)
              Image.file(imageFile!, height: 100, width: 100, fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    typeController.dispose();
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }
}

class EditMenu extends StatefulWidget {
  static show(BuildContext context, {required MenuItem menu,required FirebaseServices controller}) =>
      showDialog(
        context: context,
        builder: (dContext) => EditMenu(menu,controller),
      );
  final MenuItem menu;
  final FirebaseServices controller;

  const EditMenu(this.menu,this.controller, {super.key});

  @override
  _EditMenuState createState() => _EditMenuState();
}

class _EditMenuState extends State<EditMenu> {
  late TextEditingController typeController, nameController, priceController;
  File? imageFile;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    typeController = TextEditingController(text: widget.menu.type);
    nameController = TextEditingController(text: widget.menu.name);
    priceController = TextEditingController(text: widget.menu.price.toString());
    imageUrl = widget.menu.imageUrl; 
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
        imageUrl = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: Text(
        "Edit menu",
        style: mMedium.copyWith(color: mBlack, fontSize: 20),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (imageFile != null) {
              await widget.controller.updateMenuItem(
                widget.menu,
                typeController.text.trim(),
                nameController.text.trim(),
                double.parse(priceController.text.trim()),
                imageFile!.path,
              );
              Navigator.of(context).pop();
            } else {
              // Handle case where no new image is picked
              await widget.controller.updateMenuItem(
                widget.menu,
                typeController.text.trim(),
                nameController.text.trim(),
                double.parse(priceController.text.trim()),
                '', // Pass empty string or imageUrl to indicate no image change
              );
              Navigator.of(context).pop();
            }
          },
          child: Text("Submit", style: mRegular.copyWith(color: mBlack, fontSize: 14)),
        )
      ],
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: "Type"),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Pick Image"),
            ),
            if (imageFile != null || imageUrl != null)
              Image.network(
                imageUrl ?? widget.menu.imageUrl,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    typeController.dispose();
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }
}
