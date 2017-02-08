//
//  RemoteComic.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/01/20.
//  Copyright (c) 2015年 Takashi Hagura. All rights reserved.
//

import Foundation

open class RemoteComic: NSObject, NSCoding {
    
    open var thumb: String?
    open var date: String?
    open var title: String?
    open var url: String?
    open var text: String?
    open var siteName: String?
    open var siteUrl: String?
    
    fileprivate let dateFormatter: DateFormatter = {
        var df = DateFormatter()
        df.locale = Locale(identifier: "en_US")
        df.dateFormat = "yyyy/MM/dd"
        return df
    }()
    
    internal enum serialization: String {
        case thumb = "thumb"
        case date = "date"
        case title = "title"
        case url = "url"
        case text = "text"
        case siteName = "siteName"
        case siteUrl = "siteUrl"
        static let values = [thumb, date, title, url, text, siteName, siteUrl]
    }
    
    public override init(){
        super.init()
        
    }
    
    public init(html: String) {
        super.init()
        self.parseHTML(html)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        
        for key in serialization.values {
            setValue(aDecoder.decodeObject(forKey: key.rawValue), forKey: key.rawValue)
        }
    }
    
    open func encode(with aCoder: NSCoder)  {
        for key in serialization.values {
            if let value: AnyObject = self.value(forKey: key.rawValue) as AnyObject? {
                aCoder.encode(value, forKey: key.rawValue)
            }
        }
    }
}

//MARK: Equatable implementation
public func ==(larg: RemoteComic, rarg: RemoteComic) -> Bool {
    return larg.url == rarg.url
}

//MARK: Network
public extension RemoteComic {
    
    public typealias CompletationCallback = (_ remoteComics: [RemoteComic]?, _ error: Fetcher.ResponseError?, _ local: Bool) -> Void
    
    public class func fetch(forList listId: String, completion: @escaping CompletationCallback) {
        fetch("/list/" + listId, completion: completion)
    }
    
    public class func fetchBookmark(_ completion: @escaping CompletationCallback) {
        fetch("/bookmark", completion: completion)
        
    }
    
    fileprivate class func fetch(_ path: String, completion: @escaping CompletationCallback) {
        Fetcher.Fetch(Constants.WEB_MANGA_ANTENNA_URL + path,
            parsing: {(html) in
                if let realHtml = html {
                    let RemoteComics = self.parseCollectionHTML(realHtml)
                    return RemoteComics as AnyObject!
                }
                else {
                    return nil
                }
            },
            completion: {(object, error, local) in
                if let realObject = object as! [RemoteComic]? {
                    completion(realObject, error, local)
                }
                else {
                    completion([],error, local)
                }
        })
    }
}

//MARK: HTML
internal extension RemoteComic {
    
    internal class func parseCollectionHTML(_ html: String) -> [RemoteComic] {
        let components = html.components(separatedBy: "<div class=\"entry\">")
        var RemoteComics: [RemoteComic] = []
        if (components.count > 0) {
            var index = 0
            for component in components {
                if index != 0 {
                    RemoteComics.append(RemoteComic(html: component))
                }
                index += 1
            }
        }
        return RemoteComics
    }
    
    internal func parseHTML(_ html: String) {
        let scanner = Scanner(string: html)
        self.thumb = scanner.scanTag("target=\"_blank\"><img src=\"", endTag: "\" width=")
        self.date = scanner.scanTag("<div class=\"entry-date\">", endTag: "</div>")
        
        let titleLink = scanner.scanTag("<div class=\"entry-title\">", endTag: "</div>")
        self.title = String.stringByRemovingHTMLEntities(titleLink)
        self.url = String.stringByHrefAttribute(titleLink)
        
        let siteLink = scanner.scanTag("<div class=\"entry-site\">", endTag: "</div>")
        self.siteName = String.stringByRemovingHTMLEntities(siteLink)
        self.siteUrl = String.stringByHrefAttribute(siteLink)
    }
}
