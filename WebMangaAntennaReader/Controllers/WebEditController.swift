//
//  WebEditController.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/11/14.
//  Copyright © 2015年 Takashi Hagura. All rights reserved.
//

import UIKit

class WebEditController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    private var _url:String? = nil
    private var indicator:UIActivityIndicatorView? = nil
    
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
        if let urlStr:String = _url {
            if let url = NSURL(string: urlStr) {
                let req = NSURLRequest(URL: url)
                webView.loadRequest(req)
            }
        }
    }
    
    @IBAction func done(sender: AnyObject) {
        let comicDao:ComicDao = ComicDao(appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
        comicDao.deleteAll()
    }
}
