import 'package:flutter/material.dart';
import 'package:flutter_ui_challenge/screens/donut.dart';
import 'package:flutter_ui_challenge/screens/fruit_salad.dart';
import 'package:flutter_ui_challenge/screens/mapscreen.dart';
import 'package:flutter_ui_challenge/screens/tab_page.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

void main() {
  runApp(MaterialApp(home: MapScreen()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController controller = TextEditingController();
  Razorpay _razorpay;
@override
  void initState() {
    // TODO: implement initState
  _razorpay=Razorpay();
  _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
  _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }


  void _handlePaymentSuccess(PaymentSuccessResponse response) {
  print("success${response.orderId}");
  print("success${response.paymentId}");
  print("success${response.signature}");
    // Do something when payment succeeds
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print("failure${response.message}");
    print("failure${response.code}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
    print("wallet${response.walletName}");
  }

  void openPayment(){
    var options = {
      'key': 'rzp_test_MBEE7Rzn5Y9wq1',
      'amount': num.tryParse(controller.text),
      'name': 'Devrabbit',
      'description': 'Fine T-Shirt',
      'prefill': {
        'contact': '9014561457',
        'email': 'anjireddyy.avula@gmail.com'
      },
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }

  }
  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("RazorPay"),centerTitle: true,),

        body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Text(DateTime.now().millisecondsSinceEpoch.toString()),
              SizedBox(height: 10,),
              TextField(
                controller: controller,
                decoration: InputDecoration(hintText: "Amount"),
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                onPressed: () {
                  openPayment();
                },
                child: Text("Submit"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
