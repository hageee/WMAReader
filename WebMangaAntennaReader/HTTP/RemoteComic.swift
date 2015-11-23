//
//  RemoteComic.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/01/20.
//  Copyright (c) 2015年 Takashi Hagura. All rights reserved.
//

import Foundation

public class RemoteComic: NSObject, NSCoding {
    
    public var thumb: String?
    public var date: String?
    public var title: String?
    public var url: String?
    public var text: String?
    public var siteName: String?
    public var siteUrl: String?
    
    private let dateFormatter: NSDateFormatter = {
        var df = NSDateFormatter()
        df.locale = NSLocale(localeIdentifier: "en_US")
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
            setValue(aDecoder.decodeObjectForKey(key.rawValue), forKey: key.rawValue)
        }
    }
    
    public func encodeWithCoder(aCoder: NSCoder)  {
        for key in serialization.values {
            if let value: AnyObject = self.valueForKey(key.rawValue) {
                aCoder.encodeObject(value, forKey: key.rawValue)
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
    
    public typealias CompletationCallback = (remoteComics: [RemoteComic]!, error: Fetcher.ResponseError!, local: Bool) -> Void
    
    public class func fetch(forList listId: String, completion: CompletationCallback) {
        fetch("/list/" + listId, completion: completion)
    }
    
    public class func fetchBookmark(completion: CompletationCallback) {
        fetch("/bookmark", completion: completion)
        
    }
    
    private class func fetch(path: String, completion: CompletationCallback) {
        Fetcher.Fetch(Constants.WEB_MANGA_ANTENNA_URL + path,
            parsing: {(html) in
                if let realHtml = html {
                    let RemoteComics = self.parseCollectionHTML(realHtml)
                    return RemoteComics
                }
                else {
                    return nil
                }
            },
            completion: {(object, error, local) in
                if let realObject: AnyObject = object {
                    completion(remoteComics: realObject as! [RemoteComic], error: error, local: local)
                }
                else {
                    completion(remoteComics: [], error: error, local: local)
                }
        })
    }
}

//MARK: HTML
internal extension RemoteComic {
    
    internal class func parseCollectionHTML(html: String) -> [RemoteComic] {
        let components = html.componentsSeparatedByString("<div class=\"entry\">")
        var RemoteComics: [RemoteComic] = []
        if (components.count > 0) {
            var index = 0
            for component in components {
                if index != 0 {
                    RemoteComics.append(RemoteComic(html: component))
                }
                index++
            }
        }
        return RemoteComics
    }
    
    internal func parseHTML(html: String) {
        let scanner = NSScanner(string: html)
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