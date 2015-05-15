//
//  Constants.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/04/16.
//  Copyright (c) 2015年 Takashi Hagura. All rights reserved.
//

import Foundation

public struct Constants {
    
    public static let WEB_MANGA_ANTENNA_URL:String = "http://webcomics.jp/"
    
    public struct UserDefaultsKeys {
        public static let MY_LIST_ID:String = "myListId"
        public static let UPDATE_CHECK_INTERVAL:String = "updateCheckInterval"
    }
    public struct Seques {
        public static let SHOW_WEB_SITE:String = "showWebSite"
        public static let SHOW_SETTING:String = "showSetting"
        public static let SHOW_INIT:String = "showInit"
        public static let UNWIND_SETTING:String = "unwindSetting"
        public static let UNWIND_LIST_SETTING:String = "unwindListSetting"
    }
    public struct Notifications {
        public static let UPDATE_COMIC:String = "updateComic"
    }
}
