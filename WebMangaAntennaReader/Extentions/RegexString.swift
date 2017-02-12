//
//  RegexString.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2017/02/12.
//  Copyright © 2017年 Takashi Hagura. All rights reserved.
//

import Foundation


extension String {
    func matches(_ pattern: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let nsString = self as NSString
            let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func test(_ pattern: String) -> Bool {
        return matches(pattern).count > 0
    }
}
