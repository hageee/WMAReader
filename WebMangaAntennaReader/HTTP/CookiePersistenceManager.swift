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
        if let cookieData = UserDefaults.standard.data(forKey: Constants.UserDefaultsKeys.COOKIE) {
            let cookies:[HTTPCookie] = NSKeyedUnarchiver.unarchiveObject(with: cookieData) as! [HTTPCookie]
            for cookie in cookies {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
    }
    
    func saveCookie() -> Void {
        if let cookies:[HTTPCookie] = HTTPCookieStorage.shared.cookies {
            let cookieData = NSKeyedArchiver.archivedData(withRootObject: cookies)
            UserDefaults.standard.set(cookieData, forKey: Constants.UserDefaultsKeys.COOKIE)
        }
    }

}
