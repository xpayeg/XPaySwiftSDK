# XPaySwiftSDK

## Installation

XPaySwiftSDK is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'XPaySwiftSDK', :git => 'https://github.com/xpayeg/XPaySwiftSDK.git'
```

## Usage

```swift

import UIKit
import XPaySwiftSDK

class ViewController: UIViewController {
    // => Add this
    var xpayUtils: XPayUtils!

    override func viewDidLoad() {
      super.viewDidLoad()

      // => Add this
      xpayUtils = XPayUtils(
        from: self,                          // ViewController instance
        sdkMode: XPaySDKMode.DEVELOPMENT,    // XPaySDKMode.LIVE for production mode
        apiKey: "API_KEY",                   // Your api key, Create an api key => https://xpayeg.github.io/docs/api-key
        apiPaymentId: 1,                     // Your api payment id, Create an api payment id => https://xpayeg.github.io/docs/api-payments
        communityId: "COMMUNITY_ID"          // Your community id, Get your community id => https://xpayeg.github.io/docs/community-id
      )

    }

    @objc func payNow() {
      xpayUtils.makePayment(
        amount: 100.0,                        // Float
        originalAmount: 100.0,                // Float
        payUsing: XPayPaymentMethod.card,     // XPayPaymentMethod.card || XPayPaymentMethod.fawry || XPayPaymentMethod.meezaDigital
        billingData: (
          name: "Full Name",             // String, Must match Regex("^[a-zA-Z\\u0621-\\u064A-]{3,}(?:\\s[a-zA-Z\\u0621-\\u064A-]{3,})+\$")
          email: "email@email.com",      // String, Must match Regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z.-]+[.][a-zA-Z]{2,4}\$")
          phoneNumber: "+201112223330"   // String, Must match Regex("^\\+[0-9]{7,15}\$")
        )
      ){ [weak self] result in
        DispatchQueue.main.async {
          switch result {
            case .success(let data):
                print("Data: \(data)")
                // Handle success, e.g., update UI or display a message
                self?.getTransactionDetails(transactionUUID: data.transactionUUID)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                // Handle error, e.g., show an alert
          }
        }
      }
    }

    @objc func getTransactionDetails(transactionUUID: String) {
      xpayUtils.getTransaction(
        transactionUUID: transactionUUID
      ){ [weak self] result in
        DispatchQueue.main.async {
          switch result {
            case .success(let data):
                print("Data: \(data)")
                // Handle success, e.g., update UI or display a message
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                // Handle error, e.g., show an alert
          }
        }
      }
    }


}

```

## Demo

https://github.com/arXpay/XPay-iOS-Demo
