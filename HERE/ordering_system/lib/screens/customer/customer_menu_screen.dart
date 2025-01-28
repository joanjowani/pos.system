import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ordering_system/auth/authcontroller.dart';
import 'package:ordering_system/dialog/dialog.dart';
import 'package:ordering_system/firebase/services.dart';
import 'package:ordering_system/model/menu.dart';
import 'package:ordering_system/model/user.dart' as custom_user;
import 'package:ordering_system/screens/customer/item_detail.dart';
import 'package:ordering_system/util/app_style.dart';
import 'package:ordering_system/util/size_config.dart';
import 'package:provider/provider.dart';

class CustomerMenuScreen extends StatefulWidget {
  static const String route = '/customermenu';

  static const String name = 'CustomerMenuScreen';
  const CustomerMenuScreen({super.key});

  @override
  State<CustomerMenuScreen> createState() => _CustomerMenuScreenState();
}

class _CustomerMenuScreenState extends State<CustomerMenuScreen> {
  late TextEditingController searchController;
  firebase_auth.User? currentUser;
  custom_user.User? currentUserinfo;
  String selectedTag = 'All';

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    _initialize();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _initialize() {
    _getCurrentUser();
    Provider.of<FirebaseServices>(context, listen: false).fetchMenuItems();
  }

  void _getCurrentUser() {
    currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _loadCurrentUser();
    }
  }

  Future<void> _loadCurrentUser() async {
    if (currentUser != null) {
      try {
        custom_user.User user =
            await Provider.of<FirebaseServices>(context, listen: false)
                .findUser(currentUser!);
        setState(() {
          currentUserinfo = user;
        });
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  List<MenuItem> _filterMenuItems(String tag, List<MenuItem> menuItems) {
    if (tag == 'All') {
      return menuItems;
    } else {
      return menuItems.where((item) => item.type == tag).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.only(left: 10.0),
          height: 20,
          child: Text(
            "Hi ${currentUserinfo?.firstName ?? ''} ${currentUserinfo?.lastName ?? ''} !",
            style: mRegular.copyWith(color: mBlack, fontSize: 18),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              WaitingDialog.show(context, future: AuthController.I.logout());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: SizeConfig.screenWidth! * 0.9,
                height: SizeConfig.blocksVertical! * 5.5,
                decoration: BoxDecoration(
                  color: mWhite,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.left,
                  controller: searchController,
                  decoration: InputDecoration(
                    filled: false,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(width: 0.2),
                    ),
                    label: Text(
                      "Search...",
                      style: mRegular.copyWith(
                          color: mGrey,
                          fontSize: SizeConfig.blocksHorizontal! * 4),
                    ),
                    prefixIcon: IconButton(
                      icon: const Icon(
                        Icons.search,
                        color: mGrey,
                        size: 25,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  "MENU",
                  style: mMedium.copyWith(
                      color: mBlack,
                      fontSize: SizeConfig.blocksHorizontal! * 5,
                      letterSpacing: 2),
                )),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTagButton("All"),
                  _buildTagButton("Breakfast"),
                  _buildTagButton("Burgers"),
                  _buildTagButton("Pizza"),
                  _buildTagButton("Dessert"),
                  _buildTagButton("Drinks"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<FirebaseServices>(
                builder: (context, firebaseServices, child) {
                  List<MenuItem> filteredMenuItems =
                      _filterMenuItems(selectedTag, firebaseServices.menuItems);
                  return ListView.builder(
                    itemCount: filteredMenuItems.length,
                    itemBuilder: (context, index) {
                      MenuItem item = filteredMenuItems[index];
                      return GestureDetector(
                        child: ListTile(
                          leading: Image.network(item.imageUrl),
                          title: Text(
                            item.name,
                            style: mRegular.copyWith(
                                color: mBlack,
                                fontSize: SizeConfig.blocksHorizontal! * 4),
                          ),
                          subtitle: Text(
                            item.type,
                            style: mRegular.copyWith(
                                color: mGrey,
                                fontSize: SizeConfig.blocksHorizontal! * 3),
                          ),
                          trailing: Text(
                            '${item.price} PHP',
                            style: mRegular.copyWith(
                                color: mGrey,
                                fontSize: SizeConfig.blocksHorizontal! * 3),
                          ),
                        ),
                        onTap: () {
                          context.push(ItemDetail.route, extra: item);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagButton(String tagName) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedTag = tagName;
          });
        },
        style: orangeTagButton,
        child: Text(
          tagName,
          style: mRegular.copyWith(
            color: mBlack,
            fontSize: SizeConfig.blocksHorizontal! * 4,
          ),
        ),
      ),
    );
  }
}
