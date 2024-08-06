//
//  WebViewHandler.swift
//
//  Created by XPay on 26/07/2024.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    private let url: URL
    
    // Closures for callbacks
    var onFinishPayment: (() -> Void)?
    var onStartLoading: ((URL) -> Void)?
    var onFinishLoading: ((URL) -> Void)?
    var onLoadingFailed: ((URL, Error) -> Void)?
    var onNavigationChange: ((WKNavigationAction) -> Void)?
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webView = WKWebView(frame: self.view.bounds)
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        webView.load(URLRequest(url: url))
        
        setupCloseButton()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.onFinishPayment?()
    }
    
    private func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Done", for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(closeWebView), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -1),
            closeButton.widthAnchor.constraint(equalToConstant: 80),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func closeWebView() {
        self.dismiss(animated: true)
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        onStartLoading?(url)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onFinishLoading?(url)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        onLoadingFailed?(url, error)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        onNavigationChange?(navigationAction)
        decisionHandler(.allow)
    }
}
