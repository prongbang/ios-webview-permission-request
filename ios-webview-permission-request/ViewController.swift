//
//  ViewController.swift
//  ios-webview-permission-request
//
//  Created by Endtry on 25/8/2563 BE.
//  Copyright © 2563 Innotech Development. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation
import SafariServices

class ViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    private var activityIndicatorContainer: UIView!
    private var activityIndicator: UIActivityIndicatorView!
    
    private let webUrl = "https://www.the-qrcode-generator.com/scan"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.grantCameraPermission()
    }
    
    private func grantCameraPermission() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthorizationStatus {
        case .authorized:
            print("present you viewcontroller")
            //            self.loadWebView()
            DispatchQueue.main.async {
                self.loadSafari()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    DispatchQueue.main.async {
                        self.loadWebView()
                    }
                }
            })
        case .denied, .restricted:
            self.showPhoneSettings()
            print("denied")
        default:
            fatalError("Camera Authorization Status not handled!")
        }
    }
    
    private func loadSafari() {
        if let url = URL(string: self.webUrl) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
    private func loadWebView() {
        self.setActivityIndicator()
        self.showActivityIndicator(show: true)
        
        let myURL = URL(string:webUrl)
        let myRequest = URLRequest(url: myURL!)
        webView.navigationDelegate = self
        webView.load(myRequest)
    }
    
    private func showPhoneSettings() {
        let alertController = UIAlertController(title: "Permission Error", message: "Permission denied, please allow our app permission through Settings in your phone if you want to use our service.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle user opened phone Settings
                })
            }
        })
        
        present(alertController, animated: true)
    }
    
    fileprivate func setActivityIndicator() {
        activityIndicatorContainer = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        activityIndicatorContainer.center.x = webView.center.x
        activityIndicatorContainer.center.y = webView.center.y - 44
        activityIndicatorContainer.backgroundColor = UIColor.black
        activityIndicatorContainer.alpha = 0.8
        activityIndicatorContainer.layer.cornerRadius = 10
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorContainer.addSubview(activityIndicator)
        webView.addSubview(activityIndicatorContainer)
        
        activityIndicator.centerXAnchor.constraint(equalTo: activityIndicatorContainer.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: activityIndicatorContainer.centerYAnchor).isActive = true
    }
    
    fileprivate func showActivityIndicator(show: Bool) {
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            activityIndicatorContainer.removeFromSuperview()
        }
    }
    
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.showActivityIndicator(show: false)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.showActivityIndicator(show: false)
    }
}
