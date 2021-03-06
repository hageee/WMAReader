//
//  HTMLString.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/01/21.
//  Copyright (c) 2015年 Takashi Hagura. All rights reserved.
//

import Foundation

extension String {
    static func stringByRemovingHTMLEntities(_ string: String) -> String {
        var result = string.replacingOccurrences(of: "<p>", with: "\n\n", options: .caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "</p>", with: "", options: .caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "<i>", with: "", options: .caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "</i>", with: "", options: .caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "&#38;", with: "&", options: .caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "&#62;", with: ">", options: .caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "&#x27;", with: "'", options: .caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "&#x2F;", with: "/", options: .caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "&quot;", with: "\"", options: .caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "&#60;", with: "<", options: .caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "&lt;", with: "<", options: .caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "&gt;", with: ">", options: .caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "&amp;", with: "&", options: .caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "<pre><code>", with: "", options: .caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "</code></pre>", with: "", options: .caseInsensitive, range: nil)
        
        let regex = try! NSRegularExpression(pattern: "<a[^>]+href=\".*?\"[^>]*>(.*?)</a>", options: NSRegularExpression.Options.caseInsensitive)
        result = regex.stringByReplacingMatches(in: result, options: [], range: NSMakeRange(0, result.utf16.count), withTemplate: "$1")
        
        return result
    }
    
    static func stringByHrefAttribute(_ string: String) -> String {
        let regex = try! NSRegularExpression(pattern: "<a[^>]+href=\"(.*?)\"[^>]*>.*?</a>", options: NSRegularExpression.Options.caseInsensitive)
        let result = regex.stringByReplacingMatches(in: string, options: [], range: NSMakeRange(0, string.utf16.count), withTemplate: "$1")
        return result
    }
    
}
