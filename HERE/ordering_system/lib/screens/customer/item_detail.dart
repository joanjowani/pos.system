import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:ordering_system/firebase/services.dart';
import 'package:ordering_system/model/menu.dart';
import 'package:ordering_system/model/user.dart' as custom_user;
import 'package:ordering_system/util/app_style.dart';
import 'package:ordering_system/util/size_config.dart';
import 'package:provider/provider.dart';

class ItemDetail extends StatefulWidget {
  static const String route = '/itemdetail';

  static const String name = 'ItemDetailScreen';

  final MenuItem item;

  const ItemDetail({super.key, required this.item});

  @override
  State<ItemDetail> createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  firebase_auth.User? currentUser;
  custom_user.User? currentUserinfo;
  int quantity = 1;
  double total = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  @override
  void dispose() {
    super.dispose();
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

  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  void getTotal() {
    setState(() {
      total = widget.item.price * quantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.item.name,
          style: mMedium.copyWith(
              color: mBlack, fontSize: SizeConfig.blocksHorizontal! * 5),
        ),
      ),
      body: Column(
        children: [
          Image.network(widget.item.imageUrl),
          SizedBox(
            height: SizeConfig.blocksHorizontal! * 3,
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Type: ${widget.item.type}',
                  style: mRegular.copyWith(
                      color: mBlack,
                      fontSize: SizeConfig.blocksHorizontal! * 5),
                ),
                Text(
                  '${widget.item.price} PHP',
                  style: mRegular.copyWith(
                      color: mBlack,
                      fontSize: SizeConfig.blocksHorizontal! * 5),
                ),
              ],
            ),
          ),
          SizedBox(
            height: SizeConfig.blocksHorizontal! * 3,
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: decrementQuantity,
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  '$quantity',
                  style: mRegular.copyWith(
                    color: mBlack,
                    fontSize: SizeConfig.blocksHorizontal! * 5,
                  ),
                ),
                IconButton(
                  onPressed: incrementQuantity,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          // SizedBox(height: SizeConfig.screenHeight!/9,),
        ],
      ),
      bottomSheet: ElevatedButton(
          style: longButtonOrange,
          onPressed: () {
            getTotal();
            addtoCart(
                widget.item,
                currentUserinfo,
                widget.item.type,
                widget.item.name,
                widget.item.price,
                quantity,
                total,
                widget.item.imageUrl);
          },
          child: Text(
            "Add to Basket",
            style: mRegular.copyWith(
                color: mBlack, fontSize: SizeConfig.blocksHorizontal! * 4),
          )),
    );
  }

  Future<void> addtoCart(
      MenuItem item,
      custom_user.User? user,
      String type,
      String name,
      double price,
      int quantity,
      double total,
      String imageFilePath) async {
    String userID = user!.id;
    String itemID = item.id;
    Provider.of<FirebaseServices>(context, listen: false).addCartItem(
        itemID, userID, type, name, price, quantity, total, imageFilePath);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name added to the cart')),
    );
  }
}
