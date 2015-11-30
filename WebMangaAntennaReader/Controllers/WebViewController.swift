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
    
    private var indicator:UIActivityIndicatorView? = nil
    private var _url:String? = nil
    private var _title:String? = nil
    
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
        goBackButton.enabled = false;
        goForwardButton.enabled = false;
        addIndicator()
    }
    
    @IBAction func goBack(sender: AnyObject) {
        webView.goBack()
    }
    
    @IBAction func goForward(sender: AnyObject) {
        webView.goForward()
    }
    
    @IBAction func openURL(sender: AnyObject) {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let openSafari:UIAlertAction = UIAlertAction(title: "Sarafiで開く",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction) -> Void in
                if let urlStr = self.webView.stringByEvaluatingJavaScriptFromString("document.URL") {
                    if let url = NSURL(string: urlStr) {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
        })
        
        let cancel:UIAlertAction = UIAlertAction(title: "キャンセル",
            style: UIAlertActionStyle.Cancel,
            handler:{
                (action:UIAlertAction) -> Void in
        })
        alert.addAction(openSafari)
        alert.addAction(cancel)
        alert.popoverPresentationController?.barButtonItem = openButton
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func refresh(sender: AnyObject) {
        webView.reload()
    }
    
    private func addIndicator() {
        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        indicator?.frame = CGRectMake(0, 0, 48, 48)
        indicator?.center = self.view.center;
        indicator?.hidesWhenStopped = true;
        self.view.addSubview(indicator!)
    }
    
    private func getWebPageTitle() -> String {
        if let webPageTitle = webView.stringByEvaluatingJavaScriptFromString("document.title") {
            return webPageTitle
        }
        return ""
    }
    
    private func loadURL() {
        if let urlStr:String = _url {
            if let url = NSURL(string: urlStr) {
                let req = NSURLRequest(URL: url)
                webView.loadRequest(req)
            }
        }
    }
    
    // UIWebViewDelegate
    
    func webViewDidStartLoad(webView: UIWebView) {
        indicator?.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if let _ = indicator?.isAnimating() {
            indicator?.stopAnimating()
        }
        if (self.title == nil) {
            self.title = getWebPageTitle()
        }
        goBackButton.enabled = webView.canGoBack;
        goForwardButton.enabled = webView.canGoForward;
    }
    
}
