import 'package:flutter/material.dart';
import 'package:ordering_system/firebase/services.dart';
import 'package:ordering_system/model/cart.dart';
import 'package:ordering_system/util/app_style.dart';
import 'package:ordering_system/util/size_config.dart';
import 'package:provider/provider.dart';

class CustomerCartScreen extends StatefulWidget {
  static const String route = '/customercart';

  static const String name = 'CustomerCartScreen';
  const CustomerCartScreen({super.key});

  @override
  State<CustomerCartScreen> createState() => _CustomerCartScreenState();
}

class _CustomerCartScreenState extends State<CustomerCartScreen> {
  double cartTotal = 0.0;

  @override
  void initState() {
    super.initState();
    Provider.of<FirebaseServices>(context, listen: false).fetchCartItems();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Order",
          style: mMedium.copyWith(
              color: mBlack, fontSize: SizeConfig.blocksHorizontal! * 5),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Consumer<FirebaseServices>(
                builder: (context, cartProvider, _) {
                  if (cartProvider.cartItems.isEmpty) {
                    return Center(
                      child: Text(
                        "Cart is empty",
                        style: mRegular.copyWith(
                            color: mBlack,
                            fontSize: SizeConfig.blocksHorizontal! * 5),
                      ),
                    );
                  } else {
                    cartTotal = calculateCartTotal(cartProvider.cartItems);

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: cartProvider.cartItems.length,
                            itemBuilder: (context, index) {
                              CartItem cartItem = cartProvider.cartItems[index];
                              return Card(
                                elevation: 4,
                                child: ListTile(
                                  leading: Image.network(cartItem.imageUrl),
                                  title: Text(
                                    cartItem.name,
                                    style: mRegular.copyWith(
                                        color: mBlack, fontSize: 16),
                                  ),
                                  subtitle: Text(
                                      'Qty: ${cartItem.quantity} - P${cartItem.total.toStringAsFixed(2)}',
                                      style: mRegular.copyWith(
                                          color: mGrey, fontSize: 14)),
                                  trailing: IconButton(
                                    onPressed: () {
                                      deleteMenuItem(context, cartItem.id);
                                    },
                                    icon: const Icon(Icons.delete),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: longButtonOrange,
                          onPressed: () async {
                            await Provider.of<FirebaseServices>(context,
                                    listen: false)
                                .placeOrder(cartProvider.cartItems, cartTotal);
                          },
                          child: Text(
                            "Place Order PHP${cartTotal.toStringAsFixed(2)}",
                            style: mRegular.copyWith(
                                color: mBlack,
                                fontSize: SizeConfig.blocksHorizontal! * 4),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  double calculateCartTotal(List<CartItem> cartItems) {
    double total = 0.0;
    for (var item in cartItems) {
      total += item.total;
    }
    return total;
  }

  void deleteMenuItem(BuildContext context, String cartItemID) async {
    try {
      await Provider.of<FirebaseServices>(context, listen: false)
          .deleteCartItem(cartItemID);
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
