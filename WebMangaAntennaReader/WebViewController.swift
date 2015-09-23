//
//  WebViewController.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/04/11.
//  Copyright (c) 2015年 Takashi Hagura. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    private var _comic:Comic? = nil
    private var indicator:UIActivityIndicatorView? = nil
    
    var comic: Comic? {
        get {
            return _comic
        }
        set(newValue) {
            _comic = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = comic?.title
        showIndicator()
        loadURL()
    }
    
    private func showIndicator() {
        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        indicator?.frame = CGRectMake(0, 0, 48, 48)
        indicator?.center = self.view.center;
        indicator?.hidesWhenStopped = true;
        indicator?.startAnimating()
        self.view.addSubview(indicator!)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        indicator?.stopAnimating()
    }
    
    private func loadURL() {
        if let urlStr:String = _comic?.url {
            if let url = NSURL(string: urlStr) {
                let req = NSURLRequest(URL: url)
                webView.loadRequest(req)
            }
        }
    }
    
    @IBAction func selectAction(sender: AnyObject) {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let openSafari:UIAlertAction = UIAlertAction(title: "Sarafiで開く",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction) -> Void in
                if let urlStr:String = self._comic?.url {
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
        presentViewController(alert, animated: true, completion: nil)
    }
}