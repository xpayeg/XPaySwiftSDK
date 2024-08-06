//
//  XPayUtils.swift
//
//  Created by XPay on 26/07/2024.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import Foundation

// enums

public enum XPaySDKMode {
    case LIVE
    case DEVELOPMENT
}

public enum XPayCurrency: String {
    case EGP, USD, EUR, SAR, AED, GBP
}

public enum XPayPaymentMethod: String {
    case card, fawry, meezaDigital = "meeza/digital"
}

public struct XPayStatus: Decodable {
    public let code: Int
    public let message: String
    public let errors: [String]
}

public struct XPayResponse<T: Decodable>: Decodable {
    public let status: XPayStatus
    public let data: T
    public let count: Int?
    public let next: String?
    public let previous: String?
}

public struct PrepareAmountData: Decodable {
    public let totalAmount: Float
    public let totalAmountCurrency: String
    
    public enum CodingKeys: String, CodingKey {
        case totalAmount = "total_amount"
        case totalAmountCurrency = "total_amount_currency"
    }
}

public struct MakePaymentData: Decodable {
    public let iframeURL: String
    public let transactionID: Int
    public let transactionStatus: String
    public let transactionUUID: String
    
    public enum CodingKeys: String, CodingKey {
        case iframeURL = "iframe_url"
        case transactionID = "transaction_id"
        case transactionStatus = "transaction_status"
        case transactionUUID = "transaction_uuid"
    }
}

public struct TransactionData: Decodable {
    public let created: String
    public let id: Int
    public let uuid: String
    public let memberID: String?
    public let totalAmount: String
    public let totalAmountCurrency: String
    public let paymentFor: String
    public let paymentForNumber: Int?
    public let status: String
    public let totalAmountPiasters: Int
    
    public enum CodingKeys: String, CodingKey {
        case created, id, uuid
        case memberID = "member_id"
        case totalAmount = "total_amount"
        case totalAmountCurrency = "total_amount_currency"
        case paymentFor = "payment_for"
        case paymentForNumber = "payment_for_number"
        case status
        case totalAmountPiasters = "total_amount_piasters"
    }
}

// XPayUtils class

public class XPayUtils {
    private var viewControllerInstance: UIViewController
    private var sdkMode: XPaySDKMode
    private var baseURL: String
    private var apiKey: String
    private var apiPaymentId: Int
    private var communityId: String
    
    public init(
        from viewControllerInstance: UIViewController,
        sdkMode: XPaySDKMode = .DEVELOPMENT,
        apiKey: String,
        apiPaymentId: Int,
        communityId: String
    ) {
        self.viewControllerInstance = viewControllerInstance
        self.sdkMode = sdkMode
        self.apiKey = apiKey
        self.apiPaymentId = apiPaymentId
        self.communityId = communityId
        self.baseURL = {
            switch sdkMode {
            case .DEVELOPMENT:
                return "https://staging.xpay.app/api/"
            case .LIVE:
                return "https://community.xpay.app/api/"
            }
        }()
    }
    
    public func prepareAmount(
        amount: Float,
        completion: @escaping (Result<PrepareAmountData, Error>) -> Void
    ) {
        let url = URL(string: "\(baseURL)v1/payments/prepare-amount/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        let body: [String: Any] = [
            "community_id": communityId,
            "amount": amount
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(XPayResponse<PrepareAmountData>.self, from: data)
                completion(.success(response.data))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    public func makePayment(
        amount: Float,
        originalAmount: Float,
        currency: XPayCurrency = .EGP,
        payUsing: XPayPaymentMethod,
        billingData: (
            name: String,
            email: String,
            phoneNumber: String),
        completion: @escaping (Result<MakePaymentData, Error>) -> Void
    ) {
        let url = URL(string: "\(baseURL)v1/payments/pay/variable-amount")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        let body: [String: Any] = [
            "community_id": communityId,
            "amount": amount,
            "original_amount": originalAmount,
            "currency": currency.rawValue,
            "variable_amount_id": apiPaymentId,
            "pay_using": payUsing.rawValue,
            "billing_data": [
                "name": billingData.name,
                "email": billingData.email,
                "phone_number": billingData.phoneNumber
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let noDataError = NSError(domain: "No data", code: 0, userInfo: nil)
                completion(.failure(noDataError))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(XPayResponse<MakePaymentData>.self, from: data)
                
                // Use self explicitly to call openWebView
                self?.openWebView(response: response){result in
                    switch result {
                    case .success(_):
                        // Handle success
                        completion(.success(response.data))
                    case .failure(_):
                        // Handle Failure
                        completion(.success(response.data))
                    }
                }
                
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    public func getTransaction(transactionUUID: String, completion: @escaping (Result<TransactionData, Error>) -> Void) {
        let url = URL(string: "\(baseURL)v1/communities/\(communityId)/transactions/\(transactionUUID)/")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(XPayResponse<TransactionData>.self, from: data)
                completion(.success(response.data))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func openWebView(response: XPayResponse<MakePaymentData>, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = response.data.iframeURL
        
        DispatchQueue.main.async {
            let webViewController = WebViewController(url: URL(string: url)!)
            
            // Set callback closures
            webViewController.onFinishPayment = {
                completion(.success(true))
            }
            webViewController.onStartLoading = { url in
                //                print("Started loading: \(url.absoluteString)")
            }
            webViewController.onFinishLoading = { url in
                //                print("Finished loading: \(url.absoluteString)")
            }
            webViewController.onLoadingFailed = { url, error in
                //                print("Failed to load \(url.absoluteString) with error: \(error.localizedDescription)")
            }
            webViewController.onNavigationChange = { navigationAction in
                //                print("Navigation action: \(navigationAction)")
            }
            
            self.viewControllerInstance.present(webViewController, animated: true, completion: nil)
        }
    }
    
}
