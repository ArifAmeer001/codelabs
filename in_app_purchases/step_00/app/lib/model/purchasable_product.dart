import 'package:in_app_purchase/in_app_purchase.dart';

enum ProductStatus { purchasable, purchased, pending }

// class PurchasableProduct {
//   final String title;
//   final String description;
//   final String price;
//   ProductStatus status;
//
//   PurchasableProduct(this.title, this.description, this.price)
//     : status = ProductStatus.purchasable;
// }

class PurchasableProduct {
  String get id => productDetails.id;
  String get title => productDetails.title;
  String get description => productDetails.description;
  String get price => productDetails.price;
  ProductStatus status;
  ProductDetails productDetails;

  PurchasableProduct(this.productDetails) : status = ProductStatus.purchasable;
}
