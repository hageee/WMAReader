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
        
        var regex = NSRegularExpression(pattern: "<a[^>]+href=\".*?\"[^>]*>(.*?)</a>", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!
        result = regex.stringByReplacingMatchesInString(result, options: nil, range: NSMakeRange(0, count(result.utf16)), withTemplate: "$1")
        
        return result
    }
    
    static func stringByHrefAttribute(string: String) -> String {
        var regex = NSRegularExpression(pattern: "<a[^>]+href=\"(.*?)\"[^>]*>.*?</a>", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!
        var result = regex.stringByReplacingMatchesInString(string, options: nil, range: NSMakeRange(0, count(string.utf16)), withTemplate: "$1")
        return result
    }
    
}
