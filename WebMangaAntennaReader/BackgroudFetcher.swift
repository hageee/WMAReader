//
//  BackgroudFetcher.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/11/23.
//  Copyright © 2015年 Takashi Hagura. All rights reserved.
//

import UIKit
import CoreData

class BackgroudFetcher {
    
    private var completionHandler:(UIBackgroundFetchResult) -> Void
    
    init(completionHandler: (UIBackgroundFetchResult) -> Void) {        
        self.completionHandler = completionHandler
    }

    func start() -> Void {
        NSLog("BackgroudFetcher Start")
        let ud = NSUserDefaults.standardUserDefaults()
        let syncMethod = ud.integerForKey(Constants.UserDefaultsKeys.SYNC_METHOD)
        if (syncMethod == Constants.SyncMethods.LIST_URL) {
            if let listId:String = ud.stringForKey(Constants.UserDefaultsKeys.LIST_ID) {
                RemoteComic.fetch(forList: listId, completion: fetchCallback)
            } else {
                 NSLog("Fetch didn't start because my list id is not registered.")
                self.completionHandler(UIBackgroundFetchResult.Failed)
            }
        } else {
            RemoteComic.fetchBookmark(fetchCallback)
        }
    }
    
    private func fetchCallback(remoteComics: [RemoteComic]!, error: Fetcher.ResponseError!, local: Bool) -> Void {
        let comicDao:ComicDao = ComicDao(appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
        var updatedComics:[Comic] = []
        for remoteComic in remoteComics {
            let oldUpdatedAt = comicDao.findByUrl(remoteComic.url!)?.updatedAt
            if let comic = comicDao.save(remoteComic) {
                if oldUpdatedAt != nil && oldUpdatedAt?.hasSuffix("時間前") == false  && oldUpdatedAt < comic.updatedAt {
                    updatedComics.append(comic)
                }
            }
        }
        if !updatedComics.isEmpty {
            self.notify(updatedComics)
            NSLog("Fetch Finished with NewData")
            self.completionHandler(UIBackgroundFetchResult.NewData)
        } else {
            NSLog("Fetch Finished with NoData")
            self.completionHandler(UIBackgroundFetchResult.NoData)
        }
    }
    
    private func notify(comics:[Comic]) {
        if comics.count == 0 { return }
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let topComic = comics[0]
        let notification = UILocalNotification()
        notification.fireDate = NSDate()	// すぐに通知したいので現在時刻を取得
        notification.timeZone = NSTimeZone.defaultTimeZone()
        if comics.count == 1 {
            notification.alertBody = String(format: "「%@」が更新されました！", arguments: [topComic.title])
        } else {
            let numOfComics:String = String(comics.count - 1)
            notification.alertBody = String(format: "「%@」他、%@本の漫画が更新されました！", arguments: [topComic.title, numOfComics])
        }
        notification.alertAction = "OK"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        UIApplication.sharedApplication().applicationIconBadgeNumber = 1;
    }
}