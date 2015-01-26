//
//  Fetcher.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/01/20.
//  Copyright (c) 2015年 Takashi Hagura. All rights reserved.
//

import Foundation
import UIKit

private let _Fetcher = Fetcher()

public class Fetcher {
    
    internal let baseURL = Constants.WEB_MANGA_ANTENNA_URL
    private let session = NSURLSession.sharedSession()
    
    public typealias FetchCompletion = (object: AnyObject!, error: ResponseError!, local: Bool) -> Void
    public typealias FetchParsing = (html: String!) -> AnyObject!
    public typealias FetchParsingAPI = (json: AnyObject) -> AnyObject!
    
    public enum ResponseError: String {
        case NoConnection = "You are not connected to the internet"
        case ErrorParsing = "An error occurred while fetching the requested page"
        case UnknownError = "An unknown error occurred"
    }
    
    public class var sharedInstance: Fetcher {
        return _Fetcher
    }
    
    class func Fetch(ressource: String, parsing: FetchParsing, completion: FetchCompletion) {
        
        self.showLoadingIndicator(true)
        
        var path = _Fetcher.baseURL + ressource
        var task = _Fetcher.session.dataTaskWithURL(NSURL(string: path)! , completionHandler: {(data: NSData!, response, error: NSError!) in
            if !(error != nil) {
                if let realData = data {
                    let html = NSString(data: realData, encoding: NSUTF8StringEncoding) as! String
                    var object: AnyObject! = parsing(html: html)

                    dispatch_async(dispatch_get_main_queue(), { ()->() in
                        self.showLoadingIndicator(false)
                        completion(object: object, error: nil, local: false)
                    })
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), { ()->() in
                        self.showLoadingIndicator(false)
                        completion(object: nil, error: ResponseError.UnknownError, local: false)
                    })
                }
            }
            else {
                completion(object: nil, error: ResponseError.UnknownError, local: false)
            }
        })
        task.resume()
    }
    
    class func showLoadingIndicator(show: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = show
    }
    
}