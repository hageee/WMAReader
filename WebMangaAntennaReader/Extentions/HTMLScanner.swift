//
//  HTMLScanner.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/01/21.
//  Copyright (c) 2015年 Takashi Hagura. All rights reserved.
//

import Foundation

extension Scanner {
    func scanTag(_ startTag: String, endTag: String) -> String {
        var temp: NSString? = ""
        var result: NSString? = ""
        self.scanUpTo(startTag, into: &temp)
        self.scanString(startTag, into: &temp)
        self.scanUpTo(endTag, into: &result)
        return result as! String
    }
}
