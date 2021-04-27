import 'dart:async';
import 'dart:io';
import 'package:app/components/alert_helper.dart';
import 'package:app/components/dictionary.dart';
import 'package:app/components/mybutton.dart';
import 'package:app/pages/workout.dart';
import 'package:app/services/transition.dart';
import 'package:flutter/material.dart';
import 'package:app/components/style.dart';
import 'package:app/components/item_fader.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase/store_kit_wrappers.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bootybuilder_icons.dart';
import 'loading_widget.dart';
import 'models/workout_model.dart';

class MyInAppPurchasePage extends StatefulWidget {
  final Workout workout;
  MyInAppPurchasePage({Key key, this.workout}) : super(key: key);

  @override
  _MyInAppPurchasePageState createState() => _MyInAppPurchasePageState();
}

class _MyInAppPurchasePageState extends State<MyInAppPurchasePage> {
  StreamSubscription<List<PurchaseDetails>> _subscription;

  bool _purchasePending = false;

  List<GlobalKey<ItemFaderState>> keys;
  bool isLoading = false;


  @override
  void initState()  {
    Stream purchaseUpdated = InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    });

    super.initState();

    keys = List.generate(6, (_) => GlobalKey<ItemFaderState>());
    Future.delayed(Duration.zero, () async {
      await showAll(keys);
    });
  }

  @override
  void dispose() {
    if(_subscription != null) _subscription.cancel();
    super.dispose();
  }

  showMessage(type, title, message) {
    AlertHelper(title: title, message: message, type: type)
        .alertDialog(context);
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  void handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });

    showMessage(AlertType.failure, "Sorry", "Transaction was not completed.\nPlease try again.");
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) {
      if (purchaseDetails.productID == widget.workout.productId) {
        if (purchaseDetails.status == PurchaseStatus.pending) {
          showPendingUI();
        } else if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          if (purchaseDetails.pendingCompletePurchase) {
            InAppPurchaseConnection.instance.completePurchase(purchaseDetails);
          }

          setState(() {
            _purchasePending = false;
          });

          completePurchase();
        }
      }
    });
  }

  Future showAll(__keys) async {
    for (GlobalKey<ItemFaderState> key in __keys) {
      await Future.delayed(Duration(milliseconds: 120));
      if (key.currentState != null) {
        key.currentState.show();
      } else {
        break;
      }
    }
  }

  void hideAll() async {
    for (GlobalKey<ItemFaderState> key in keys) {
      await Future.delayed(Duration(milliseconds: 120));
      if (key.currentState != null) {
        key.currentState.hide();
      } else {
        break;
      }
    }
  }

  Future _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future _startSubscription() async {
    if (_purchasePending)  return;

    setState(() {
      isLoading = true;
    });

    ProductDetailsResponse productDetailResponse = await InAppPurchaseConnection.instance
        .queryProductDetails(<String>[widget.workout.productId].toSet());

    if (productDetailResponse.error != null) {
      showMessage(
          AlertType.failure, "Failed", productDetailResponse.error.message);
      setState(() {
        _purchasePending = false;
        isLoading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      showMessage(AlertType.failure, "Failed",
          "Subscription doesn't exist in store.\nPlease contact support.");
      setState(() {
        _purchasePending = false;
        isLoading = false;
      });
      return;
    }


    final productDetails = productDetailResponse.productDetails[0];
    PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

    try {
      await InAppPurchaseConnection.instance.buyNonConsumable(purchaseParam: purchaseParam);
    } on Exception catch (_) {
      showMessage(AlertType.failure, "Sorry", "Transaction was not completed.\nPlease check and try again.");
    }


    setState(() {
      isLoading = false;
    });
  }

  Future _restoreSubscription() async {
    if (_purchasePending)  return;

    setState(() {
      isLoading = true;
    });

    if (Platform.isIOS) {
      SKPaymentQueueWrapper().restoreTransactions();
    }

    final QueryPurchaseDetailsResponse purchaseResponse =
    await InAppPurchaseConnection.instance.queryPastPurchases();

    for (PurchaseDetails purchase in purchaseResponse.pastPurchases) {
      if (purchase.productID == widget.workout.productId) {
        if (Platform.isIOS) {
          InAppPurchaseConnection.instance.completePurchase(purchase);
        }
        completePurchase();
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  void completePurchase() {
    Navigator.of(context).pushReplacement(
        Transition.createHomePageRoute(WorkoutPage(workout: widget.workout)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: MySizeStyle.pageHorizontal(context),
                      vertical: MySizeStyle.pageVertical(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ItemFader(
                        key: keys[0],
                        child: Text(
                          dictionary.subscription,
                          style: MyTextStyle.titleDarkStyle(context),
                        ),
                      ),
                      SizedBox(
                        height: MySizeStyle.design(10, context),
                      ),
                      ItemFader(
                        key: keys[1],
                        child: Text(
                          dictionary.workoutsDescription,
                          style: MyTextStyle.textStyle(context),
                        ),
                      ),
                      SizedBox(
                        height: MySizeStyle.design(15, context),
                      ),
                      ItemFader(
                        key: keys[2],
                        child: MyButton(
                          title: _purchasePending
                              ? "Purchasing"
                              : "Subscribe for \$4.99 / month",
                          onTap: _startSubscription,
                        ),
                      ),
                      SizedBox(
                        height: MySizeStyle.design(15, context),
                      ),
                      ItemFader(
                        key: keys[3],
                        child: MyButton(
                          title: "Restore Subscription",
                          type: "secondary",
                          onTap: _restoreSubscription,
                        ),
                      ),
                      SizedBox(
                        height: MySizeStyle.design(30, context),
                      ),
                      ItemFader(
                        key: keys[4],
                        child: Center(
                          child: GestureDetector(
                            child: Text(
                              dictionary.termsConditions,
                              style: MyTextStyle.smallButtonDarkStyle(context),
                            ),
                            onTap: () async =>
                            {await _launchURL('https://bootybuilder.com/terms-of-use/')},
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MySizeStyle.design(30, context),
                      ),
                      ItemFader(
                        key: keys[5],
                        child: Center(
                          child: GestureDetector(
                              child: Text(
                                dictionary.privacyPolicy,
                                style: MyTextStyle.smallButtonDarkStyle(context),
                              ),
                              onTap: () async => {
                                await _launchURL('https://bootybuilder.com/privacy-policy/')
                              }),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              child: GestureDetector(
                child: Container(
                  height: MySizeStyle.design(50, context),
                  width: MySizeStyle.design(50, context),
                  child: Center(
                    child: Icon(
                      Bootybuilder.close,
                      size: MySizeStyle.design(18, context),
                      color: MyColorStyle.foreground,
                    ),
                  ),
                ),
                onTap: () => {Navigator.of(context).pop()},
              ),
              right: MySizeStyle.design(10, context),
              top: 0,
            ),
            Center(
              child: isLoading ? LoadingWidget() : SizedBox(),
            )
          ],
        ),
      ),
    );
  }
}
