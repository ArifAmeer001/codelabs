import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';

import '../constants.dart';
import '../main.dart';
import '../model/purchasable_product.dart';
import '../model/store_state.dart';
import 'dash_counter.dart';
import 'firebase_notifier.dart';

class DashPurchases extends ChangeNotifier {
  FirebaseNotifier firebaseNotifier;
  DashCounter counter;
  StoreState storeState = StoreState.loading;
  late StreamSubscription<List<PurchaseDetails>> _subscription; //for listening to subscription stream

  bool get beautifiedDash => _beautifiedDashUpgrade;
  bool _beautifiedDashUpgrade = false;

  // List<PurchasableProduct> products = [
  //   PurchasableProduct(
  //     'Spring is in the air',
  //     'Many dashes flying out from their nests',
  //     '\$0.99',
  //   ),
  //   PurchasableProduct(
  //     'Jet engine',
  //     'Doubles you clicks per second for a day',
  //     '\$1.99',
  //   ),
  // ];

  // List<PurchasableProduct> products = [
  //   PurchasableProduct(
  //     ProductDetails(
  //       id : 'product_1',
  //       title : 'Spring is in the air',
  //       description : 'Many dashes flying out from their nests',
  //       price : '\$0.99',
  //       rawPrice: 0.99,
  //       currencyCode: 'USD',
  //     )
  //   ),
  //   PurchasableProduct(
  //     ProductDetails(
  //       id : 'product_2',
  //       title : 'Jet engine',
  //       description: 'Doubles you clicks per second for a day',
  //       price: '\$1.99',
  //       rawPrice: 1.99,
  //       currencyCode: 'USD'
  //     )
  //   ),
  // ];

  List<PurchasableProduct> products = [];

  final iapConnection = IAPConnection.instance; //Added this to get the instance of the IAPConnection

  DashPurchases(this.counter, this.firebaseNotifier) {
    final purchaseUpdated = iapConnection.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );
    loadPurchases();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  //This method will load my purchases that I have purchased
  Future<void>loadPurchases() async{
    final available = await iapConnection.isAvailable();
    if(!available){
      storeState = StoreState.notAvailable;
      notifyListeners();
      return;
    }
    const ids = <String>{
      storeKeyUpgrade,
      storeKeyConsumable,
      storeKeySubscription
    };
    final response = await iapConnection.queryProductDetails(ids);
    products = response.productDetails.map((e) => PurchasableProduct(e)).toList();
    storeState = StoreState.available;
    notifyListeners();
  }

  //Buy method which will set status to pending, then purchased and then you can again purchase it.
  Future<void> buy(PurchasableProduct product) async {
    final purchaseParam = PurchaseParam(productDetails: product.productDetails);
    switch (product.id) {
      case storeKeyConsumable:
        await iapConnection.buyConsumable(purchaseParam: purchaseParam);
      case storeKeySubscription:
      case storeKeyUpgrade:
        await iapConnection.buyNonConsumable(purchaseParam: purchaseParam);
      default:
        throw ArgumentError.value(
            product.productDetails, '${product.id} is not a known product');
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async{
    final url = Uri.parse('http://$serverIp:8080/verifypurchase');

    const header = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    final response = await http.post(
      url,
      body: jsonEncode({
        'source' : purchaseDetails.verificationData.source,
        'productId' : purchaseDetails.productID,
        'verificationData' : purchaseDetails.verificationData.serverVerificationData,
        'userId' : firebaseNotifier.user?.uid
      }),
      headers: header
    );
    if(response.statusCode == 200){
      return true;
    } else {
      return false;
    }
  }
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async{
    for(var purchaseDetail in purchaseDetailsList){
      await _handlePurchase(purchaseDetail);
    }
    notifyListeners();
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async{
    if(purchaseDetails.status == PurchaseStatus.purchased){
      switch(purchaseDetails.productID){
        case storeKeySubscription://this case will handle the subscriptions
          counter.applyPaidMultiplier();
        case storeKeyConsumable://this case will handle consumable that a user can consume again and again
          counter.addBoughtDashes(2000);
        case storeKeyUpgrade:
          _beautifiedDashUpgrade = true;
      }
    }
    if(purchaseDetails.pendingCompletePurchase){
      await iapConnection.completePurchase(purchaseDetails);
    }
  }

  void _updateStreamOnDone() {
    _subscription.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    //Handle error here
    throw UnimplementedError();
  }
}
