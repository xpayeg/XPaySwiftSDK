//
//  ViewController.swift
//  XPaySwiftSDK
//
//  Created by XPay on 07/26/2024.
//  Copyright (c) 2024 XPay. All rights reserved.
//

import UIKit
import XPaySwiftSDK

class ViewController: UIViewController {
    
    // => Add this
    var xpayUtils: XPayUtils!
    // => => => => =>
    
    let label1 = UILabel()
    let label2 = UILabel()
    let prepareButton = UIButton(type: .system)
    var label3 = UILabel()
    let payNowButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // => Add this
        xpayUtils = XPayUtils(from: self, sdkMode: XPaySDKMode.DEVELOPMENT, apiKey: "Cce74Y3B.J0P4tItq7hGu2ddhCB0WF5ND1eTubkpT", apiPaymentId: 60, communityId: "m2J7eBK")
        // => => => => =>
        
        // Configure labels
        label1.text = "Total Payment"
        label1.font = UIFont.boldSystemFont(ofSize: 24)
        label1.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        label1.textAlignment = .center
        label1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label1)
        
        label2.text = "100 EGP"
        label2.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        label2.textAlignment = .center
        label2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label2)
        
        // Configure button
        prepareButton.setTitle("Prepare payment", for: .normal)
        prepareButton.translatesAutoresizingMaskIntoConstraints = false
        prepareButton.addTarget(self, action: #selector(preparePayment), for: .touchUpInside)
        view.addSubview(prepareButton)
        
        label3.text = "Payment details: "
        label3.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        label3.textAlignment = .center
        label3.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label3)
        
        // Configure button
        payNowButton.setTitle("Pay Now", for: .normal)
        payNowButton.translatesAutoresizingMaskIntoConstraints = false
        payNowButton.addTarget(self, action: #selector(payNow), for: .touchUpInside)
        view.addSubview(payNowButton)
        
        NSLayoutConstraint.activate([
            // Center labels horizontally
            label1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            prepareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label3.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            payNowButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Position label1 at the top with margin
            label1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            // Position label2 below label1
            label2.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 8),
            // Position Prepare button below label2
            prepareButton.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: 20),
            // Position label3 below Prepare button
            label3.topAnchor.constraint(equalTo: prepareButton.bottomAnchor, constant: 8),
            // Position Pay Now button below label3
            payNowButton.topAnchor.constraint(equalTo: label3.bottomAnchor, constant: 20),
            
        ])
        
    }
    
    @objc func preparePayment() {
        prepareButton.setTitle("Loading", for: .normal)
        prepareButton.isEnabled = false
        
        xpayUtils.prepareAmount(amount: 100.0) { [weak self] result in
            DispatchQueue.main.async {
                // Reset button title
                self?.prepareButton.setTitle("Prepare payment", for: .normal)
                self?.prepareButton.isEnabled = true
                
                print(result)
                
                switch result {
                case .success(let data):
                    print("Data: \(data)")
                    
                    self?.label3.text = "Payment details: \(data.totalAmount) \(data.totalAmountCurrency)"
                    // Handle success, e.g., update UI or display a message
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    // Handle error, e.g., show an alert
                }
            }
        }
    }
    
    @objc func payNow() {
        payNowButton.setTitle("Loading", for: .normal)
        payNowButton.isEnabled = false
        
        xpayUtils.makePayment(
            amount: 100.0,
            originalAmount: 100.0,
            payUsing: XPayPaymentMethod.card,
            billingData: (
                name: "Adel Reda",
                email: "adelredaa97@gmail.com",
                phoneNumber: "+201279767022")
        ){ [weak self] result in
            DispatchQueue.main.async {
                // Reset button title
                self?.payNowButton.setTitle("Pay Now", for: .normal)
                self?.payNowButton.isEnabled = true
                
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
        xpayUtils.getTransaction(transactionUUID: transactionUUID){ [weak self] result in
            DispatchQueue.main.async {
                // Reset button title
                self?.payNowButton.setTitle("Prepare", for: .normal)
                self?.payNowButton.isEnabled = true
                
                switch result {
                case .success(let data):
                    self?.showAlert(title: "Alert", message: "Transaction Data: \(data)")
                    // Handle success, e.g., update UI or display a message
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    // Handle error, e.g., show an alert
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

