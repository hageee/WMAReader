//
//  BackgroudFetcher.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/11/23.
//  Copyright © 2015年 Takashi Hagura. All rights reserved.
//

import UIKit
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class BackgroudFetcher {
    
    fileprivate var completionHandler:(UIBackgroundFetchResult) -> Void
    
    init(completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {        
        self.completionHandler = completionHandler
    }

    func start() -> Void {
        NSLog("Start BackgroudFetcher")
        let ud = UserDefaults.standard
        let syncMethod = ud.integer(forKey: Constants.UserDefaultsKeys.SYNC_METHOD)
        if (syncMethod == Constants.SyncMethods.LIST_URL) {
            if let listId:String = ud.string(forKey: Constants.UserDefaultsKeys.LIST_ID) {
                RemoteComic.fetch(forList: listId, completion: fetchCallback)
            } else {
                 NSLog("Fetch didn't start because my list id is not registered.")
                self.completionHandler(UIBackgroundFetchResult.failed)
            }
        } else {
            RemoteComic.fetchBookmark(fetchCallback)
        }
    }
    
    fileprivate func fetchCallback(_ remoteComics: [RemoteComic]?, error: Fetcher.ResponseError?, local: Bool) -> Void {
        let comicDao:ComicDao = ComicDao(appDelegate: UIApplication.shared.delegate as! AppDelegate)
        var updatedComics:[Comic] = []
        for remoteComic in remoteComics ?? [] {
            let oldUpdatedAt = comicDao.findByUrl(remoteComic.url!)?.updatedAt
            if let comic = comicDao.save(remoteComic) {
                if oldUpdatedAt != nil && oldUpdatedAt?.hasSuffix("時間前") == false  && oldUpdatedAt < comic.updatedAt {
                    updatedComics.append(comic)
                }
            }
        }
        if !updatedComics.isEmpty {
            self.notify(updatedComics)
            NSLog("Finish BackgroudFetcher with NewData")
            self.completionHandler(UIBackgroundFetchResult.newData)
        } else {
            NSLog("Finish BackgroudFetcher with NoData")
            self.completionHandler(UIBackgroundFetchResult.noData)
        }
    }
    
    fileprivate func notify(_ comics:[Comic]) {
        if comics.count == 0 { return }
        UIApplication.shared.cancelAllLocalNotifications()
        let topComic = comics[0]
        let notification = UILocalNotification()
        notification.fireDate = Date()	// すぐに通知したいので現在時刻を取得
        notification.timeZone = TimeZone.current
        if comics.count == 1 {
            notification.alertBody = String(format: "「%@」が更新されました！", arguments: [topComic.title])
        } else {
            let numOfComics:String = String(comics.count - 1)
            notification.alertBody = String(format: "「%@」他、%@本の漫画が更新されました！", arguments: [topComic.title, numOfComics])
        }
        notification.alertAction = "OK"
        let hour = (Calendar.current as NSCalendar).components([.hour], from: Date()).hour
        // 深夜〜早朝はサウンドを鳴らさない
        if !(1 <= hour! && hour! <= 7) {
            notification.soundName = UILocalNotificationDefaultSoundName
        }
        UIApplication.shared.presentLocalNotificationNow(notification)
        UIApplication.shared.applicationIconBadgeNumber = 1;
    }
}
