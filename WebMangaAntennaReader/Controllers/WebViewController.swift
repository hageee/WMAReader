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
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let openSafari:UIAlertAction = UIAlertAction(title: "Sarafiで開く",
            style: UIAlertActionStyle.default,
            handler:{
                (action:UIAlertAction) -> Void in
                if let urlStr = self.webView.stringByEvaluatingJavaScript(from: "document.URL") {
                    if let url = URL(string: urlStr) {
                        UIApplication.shared.openURL(url)
                    }
                }
        })
        
        let cancel:UIAlertAction = UIAlertAction(title: "キャンセル",
            style: UIAlertActionStyle.cancel,
            handler:{
                (action:UIAlertAction) -> Void in
        })
        alert.addAction(openSafari)
        alert.addAction(cancel)
        alert.popoverPresentationController?.barButtonItem = openButton
        present(alert, animated: true, completion: nil)
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
