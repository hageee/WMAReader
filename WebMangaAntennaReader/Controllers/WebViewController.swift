//
//  WebViewController.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/11/14.
//  Copyright © 2015年 Takashi Hagura. All rights reserved.
//

import UIKit
import Accounts

class WebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var goBackButton: UIBarButtonItem!
    @IBOutlet weak var goForwardButton: UIBarButtonItem!
    @IBOutlet weak var openButton: UIBarButtonItem!
    
    fileprivate var indicator:UIActivityIndicatorView? = nil
    fileprivate var _url:String? = nil
    fileprivate var _title:String? = nil
    
    var url: String? {
        get {
            return _url
        }
        set(newValue) {
            _url = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ページめくり中に誤ってバックするとストレスなんで、スワイプによるバックは無効にしておく
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        loadURL()
        goBackButton.isEnabled = false;
        goForwardButton.isEnabled = false;
        addIndicator()
    }
    
    @IBAction func goBack(_ sender: AnyObject) {
        webView.goBack()
    }
    
    @IBAction func goForward(_ sender: AnyObject) {
        webView.goForward()
    }
    
    @IBAction func openURL(_ sender: AnyObject) {
        if let urlStr = _url {
            if let url = URL(string: urlStr) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func refresh(_ sender: AnyObject) {
        webView.reload()
    }
    
    fileprivate func addIndicator() {
        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        indicator?.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        indicator?.center = self.view.center;
        indicator?.hidesWhenStopped = true;
        self.view.addSubview(indicator!)
    }
    
    fileprivate func getWebPageTitle() -> String {
        if let webPageTitle = webView.stringByEvaluatingJavaScript(from: "document.title") {
            return webPageTitle
        }
        return ""
    }
    
    fileprivate func loadURL() {
        if let urlStr:String = _url {
            if let url = URL(string: urlStr) {
                let req = URLRequest(url: url)
                webView.loadRequest(req)
            }
        }
    }
    
    // UIWebViewDelegate
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        indicator?.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if let _ = indicator?.isAnimating {
            indicator?.stopAnimating()
        }
        if (self.title == nil) {
            self.title = getWebPageTitle()
        }
        goBackButton.isEnabled = webView.canGoBack;
        goForwardButton.isEnabled = webView.canGoForward;
    }
    
}
