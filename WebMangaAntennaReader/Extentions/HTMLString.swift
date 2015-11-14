//
//  HTMLString.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/01/21.
//  Copyright (c) 2015年 Takashi Hagura. All rights reserved.
//

import Foundation

extension String {
    static func stringByRemovingHTMLEntities(string: String) -> String {
        var result = string.stringByReplacingOccurrencesOfString("<p>", withString: "\n\n", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("</p>", withString: "", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("<i>", withString: "", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("</i>", withString: "", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&#38;", withString: "&", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&#62;", withString: ">", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&#x27;", withString: "'", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&#x2F;", withString: "/", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&quot;", withString: "\"", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&#60;", withString: "<", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&lt;", withString: "<", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&gt;", withString: ">", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&amp;", withString: "&", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("<pre><code>", withString: "", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("</code></pre>", withString: "", options: .CaseInsensitiveSearch, range: nil)
        
        let regex = try! NSRegularExpression(pattern: "<a[^>]+href=\".*?\"[^>]*>(.*?)</a>", options: NSRegularExpressionOptions.CaseInsensitive)
        result = regex.stringByReplacingMatchesInString(result, options: [], range: NSMakeRange(0, result.utf16.count), withTemplate: "$1")
        
        return result
    }
    
    static func stringByHrefAttribute(string: String) -> String {
        let regex = try! NSRegularExpression(pattern: "<a[^>]+href=\"(.*?)\"[^>]*>.*?</a>", options: NSRegularExpressionOptions.CaseInsensitive)
        let result = regex.stringByReplacingMatchesInString(string, options: [], range: NSMakeRange(0, string.utf16.count), withTemplate: "$1")
        return result
    }
    
}
