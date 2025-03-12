import 'package:dashclicker/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

void main() {
  testWidgets('App starts', (tester) async {
    IAPConnection.instance = TestIAPConnection(); //Added this, to test the In App purchases
    await tester.pumpWidget(const MyApp());
    expect(find.text('Tim Sneath'), findsOneWidget);
  });
}

class TestIAPConnection implements InAppPurchase {

  @override
  Future<bool> buyConsumable({bool autoConsume = true, required PurchaseParam purchaseParam}){
    return Future.value(false);
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}){
    return Future.value(false);
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase){
    return Future.value();
  }

  @override
  Future<bool> isAvailable(){
    return Future.value(false);
  }

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers){
    return Future.value(
      ProductDetailsResponse(productDetails: [], notFoundIDs: [])
    );
  }

  @override
  T getPlatformAddition<T extends InAppPurchasePlatformAddition?>() {
    //Have to implement it according to the desire functionality i.e. Subscription
    throw UnimplementedError();
  }

  @override
  Stream<List<PurchaseDetails>> get purchaseStream =>
      Stream.value(<PurchaseDetails>[]);

  @override
  Future<void> restorePurchases({String? applicationUserName}) {
    //Have to implement it according to the desire functionality i.e. Subscription
    throw UnimplementedError();
  }

  @override
  Future<String> countryCode() {
    //To test the country codes
    throw UnimplementedError();
  }
}
