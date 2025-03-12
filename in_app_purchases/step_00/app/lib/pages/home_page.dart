import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../logic/dash_counter.dart';
import '../logic/dash_purchases.dart';
import '../logic/dash_upgrades.dart';
import '../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // final InAppPurchase _iap = InAppPurchase.instance;
  // final purchaseUpdated = IAPConnection.instance.purchaseStream;
  //
  // late StreamSubscription<List<PurchaseDetails>> _subscription;
  //
  // @override
  // void initState() {
  //   super.initState();
  //   testIAP();
  // }
  //
  // void testIAP() async {
  //   debugPrint("Testing");
  //   final bool available = await _iap.isAvailable();
  //   if (!available) {
  //     debugPrint("Billing service not available");
  //     return;
  //   }
  //   await fetchSubscriptions();
  //
  //   //buySubscription();
  //
  //   _subscription = purchaseUpdated.listen(
  //     _onPurchaseUpdate,
  //     onDone: _updateStreamOnDone,
  //     onError: _updateStreamOnError,
  //   );
  // }
  //
  // Future<List<ProductDetails>> fetchSubscriptions() async {
  //   debugPrint("fetch Subscription is being call");
  //   final response = await _iap.queryProductDetails(
  //     {'app_access_subscription'}.toSet(),
  //   );
  //   return response.productDetails;
  // }
  //
  // void buySubscription(ProductDetails product) {
  //   debugPrint("Attempting to buy: ${product.id}");
  //   final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
  //   _iap.buyNonConsumable(purchaseParam: purchaseParam);
  // }
  //
  //
  //
  //
  // Future<void> _onPurchaseUpdate(
  //     List<PurchaseDetails> purchaseDetailsList,
  //     ) async {
  //   for (var purchaseDetail in purchaseDetailsList) {
  //     print(purchaseDetail);
  //     await _handlePurchase(purchaseDetail);
  //   }
  //   debugPrint("On Purchase Update is being call");
  // }
  //
  // Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
  //   debugPrint("handle Purchases is being call");
  //   debugPrint(purchaseDetails.productID);
  //   if (purchaseDetails.status == PurchaseStatus.purchased) {
  //
  //     // switch(purchaseDetails.productID){
  //     // case storeKeySubscription://this case will handle the subscriptions
  //     // counter.applyPaidMultiplier();
  //     // case storeKeyConsumable://this case will handle consumable that a user can consume again and again
  //     // counter.addBoughtDashes(2000);
  //     // case storeKeyUpgrade:
  //     // _beautifiedDashUpgrade = true;
  //
  //     debugPrint("Status is set to purchased");
  //   }
  //   if (purchaseDetails.pendingCompletePurchase) {
  //     await IAPConnection.instance.completePurchase(purchaseDetails);
  //   }
  // }
  //
  // void _updateStreamOnDone() {
  //   debugPrint("update Stream Done is being call");
  //   _subscription.cancel();
  // }
  //
  // void _updateStreamOnError(dynamic error) {
  //   debugPrint("Stream Error is being handle here");
  //   //Handle error here
  //   throw UnimplementedError();
  // }



  //Previously commented this, was not using this from the start
  // void listenToPurchases(){
  //   final Stream purchaseUpdated =
  //       InAppPurchase.instance.purchaseStream;
  //   purchaseUpdated.li
  //   _subscription = purchaseUpdated.listen((purchaseDetailsList) {
  //     _listenToPurchaseUpdated(purchaseDetailsList);
  //   }, onDone: () {
  //     _subscription.cancel();
  //   }, onError: (error) {
  //     // handle error here.
  //   });
  // }

  // void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
  //   purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
  //     if (purchaseDetails.status == PurchaseStatus.pending) {
  //       // _showPendingUI();
  //       debugPrint("Pending Screen");
  //     } else {
  //       if (purchaseDetails.status == PurchaseStatus.error) {
  //         // _handleError(purchaseDetails.error!);
  //         debugPrint("Error while encountring Purchase Detail");
  //       } else if (purchaseDetails.status == PurchaseStatus.purchased ||
  //           purchaseDetails.status == PurchaseStatus.restored) {
  //         bool valid = await _verifyPurchase(purchaseDetails);
  //         if (valid) {
  //           // _deliverProduct(purchaseDetails);
  //           debugPrint("Delivering the Product");
  //         } else {
  //           // _handleInvalidPurchase(purchaseDetails);
  //           debugPrint("Handling invalid Purchases");
  //         }
  //       }
  //       if (purchaseDetails.pendingCompletePurchase) {
  //         await InAppPurchase.instance
  //             .completePurchase(purchaseDetails);
  //       }
  //     }
  //   });
  // }

  // Future<bool> isSubscribed() async {
  //   final response = await _iap.queryPastPurchases();
  //   for (var purchase in response.pastPurchases) {
  //     if (purchase.productID == 'monthly_subscription' && purchase.status == PurchaseStatus.purchased) {
  //       return true;
  //     }
  //   }
  //   return false;
  // }

  //Not using till here.

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(flex: 2, child: DashClickerWidget()),
        Expanded(child: UpgradeList()),
      ],
    );
  }
}

class DashClickerWidget extends StatelessWidget {
  const DashClickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CounterStateWidget(),
          InkWell(
            // Don't listen as we don't need a rebuild when the count changes
            onTap: Provider.of<DashCounter>(context, listen: false).increment,
            child: Image.asset(
              context.read<DashPurchases>().beautifiedDash
                  ? 'assets/dash.png'
                  : 'assets/dash_old.png',
            ),
          ),
        ],
      ),
    );
  }
}

class CounterStateWidget extends StatelessWidget {
  const CounterStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // This widget is the only widget that directly listens to the counter
    // and is thus updated almost every frame. Keep this as small as possible.
    var counter = context.watch<DashCounter>();
    return RichText(
      text: TextSpan(
        text: 'You have tapped Dash ',
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
            text: counter.countString,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: ' times!'),
        ],
      ),
    );
  }
}

class UpgradeList extends StatelessWidget {
  const UpgradeList({super.key});

  @override
  Widget build(BuildContext context) {
    var upgrades = context.watch<DashUpgrades>();
    return ListView(
      children: [
        _UpgradeWidget(
          upgrade: upgrades.tim,
          title: 'Tim Sneath',
          onPressed: upgrades.addTim,
        ),
      ],
    );
  }
}

class _UpgradeWidget extends StatelessWidget {
  final Upgrade upgrade;
  final String title;
  final VoidCallback onPressed;

  const _UpgradeWidget({
    required this.upgrade,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: ListTile(
        leading: Center(widthFactor: 1, child: Text(upgrade.count.toString())),
        title: Text(
          title,
          style:
              !upgrade.purchasable
                  ? const TextStyle(color: Colors.redAccent)
                  : null,
        ),
        subtitle: Text('Produces ${upgrade.work} dashes per second'),
        trailing: Text('${NumberFormat.compact().format(upgrade.cost)} dashes'),
      ),
    );
  }
}
