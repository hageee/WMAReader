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

open class Fetcher {
    
    fileprivate let session = URLSession.shared
    
    public typealias FetchCompletion = (_ object: AnyObject?, _ error: ResponseError?, _ local: Bool) -> Void
    public typealias FetchParsing = (_ html: String?) -> AnyObject!
    public typealias FetchParsingAPI = (_ json: AnyObject) -> AnyObject!
    
    public enum ResponseError: String {
        case NoConnection = "You are not connected to the internet"
        case ErrorParsing = "An error occurred while fetching the requested page"
        case UnknownError = "An unknown error occurred"
    }
    
    open class var sharedInstance: Fetcher {
        return _Fetcher
    }
    
    class func Fetch(_ ressource: String, parsing: @escaping FetchParsing, completion: @escaping FetchCompletion) {
        
        self.showLoadingIndicator(true)
        
        let task = _Fetcher.session.dataTask(with: URL(string: ressource)! , completionHandler: {
            (data, response, error) in
            if !(error != nil) {
                if let realData = data {
                    let html = NSString(data: realData, encoding: String.Encoding.utf8.rawValue) as! String
                    let object: AnyObject! = parsing(html)

                    DispatchQueue.main.async(execute: { ()->() in
                        self.showLoadingIndicator(false)
                        completion(object, nil, false)
                    })
                }
                else {
                    DispatchQueue.main.async(execute: { ()->() in
                        self.showLoadingIndicator(false)
                        completion(nil, ResponseError.UnknownError, false)
                    })
                }
            }
            else {
                completion(nil, ResponseError.UnknownError, false)
            }
        })
        task.resume()
    }
    
    class func showLoadingIndicator(_ show: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = show
    }
    
}
