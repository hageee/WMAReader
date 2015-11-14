//
//  CookiePersistenceManager.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/11/23.
//  Copyright © 2015年 Takashi Hagura. All rights reserved.
//

import UIKit

class CookiePersistanceManager {
    
    static let sharedInstance = CookiePersistanceManager()
    
    func loadCookie() -> Void {
        if let cookieData = NSUserDefaults.standardUserDefaults().dataForKey(Constants.UserDefaultsKeys.COOKIE) {
            let cookies:[NSHTTPCookie] = NSKeyedUnarchiver.unarchiveObjectWithData(cookieData) as! [NSHTTPCookie]
            for cookie in cookies {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie)
            }
        }
    }
    
    func saveCookie() -> Void {
        if let cookies:[NSHTTPCookie] = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies {
            let cookieData = NSKeyedArchiver.archivedDataWithRootObject(cookies)
            NSUserDefaults.standardUserDefaults().setObject(cookieData, forKey: Constants.UserDefaultsKeys.COOKIE)
        }
    }

}
