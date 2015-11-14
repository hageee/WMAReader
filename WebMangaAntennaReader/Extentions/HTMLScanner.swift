//
//  HTMLScanner.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/01/21.
//  Copyright (c) 2015年 Takashi Hagura. All rights reserved.
//

import Foundation

extension NSScanner {
    func scanTag(startTag: String, endTag: String) -> String {
        var temp: NSString? = ""
        var result: NSString? = ""
        self.scanUpToString(startTag, intoString: &temp)
        self.scanString(startTag, intoString: &temp)
        self.scanUpToString(endTag, intoString: &result)
        return result as! String
    }
}