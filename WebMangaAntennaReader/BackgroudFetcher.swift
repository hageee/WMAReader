//
//  BackgroudFetcher.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/11/23.
//  Copyright © 2015年 Takashi Hagura. All rights reserved.
//

import UIKit
import CoreData

fileprivate let REGEX_DATE = "[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}"

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
            let newComicData = comicDao.save(remoteComic)
            if let comic = newComicData {
                if BackgroudFetcher.isUpdated(oldTime: oldUpdatedAt, newTime: comic.updatedAt) {
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
    
    public static func isUpdated(oldTime:String?, newTime:String?) -> Bool {
        // @regret データ保存時に面倒がらずにDate型にパースして保存していればこんなめんどくさいことには...
        guard let oldTime = oldTime, let newTime = newTime else {
            return false
        }
        if oldTime.test(REGEX_DATE) {
            // 以前取得したデータの更新日が日付形式だった場合
            if newTime.test(REGEX_DATE) {
                // 最新データも日付形式の場合は辞書順で比較
                return oldTime < newTime
            } else {
                // 新データが日付形式でない場合、本日更新があったということなので、更新ありと判断
                return true
            }
        } else {
            // 以前取得したデータの更新日が、〜分前や、〜時間前のような形式だった場合
            if oldTime.hasSuffix("時間前") {
                if newTime.test(REGEX_DATE) {
                    // 最新更新時間が日付になっている場合は、更新から1日以上経過し表記が日付形式に変わった状態なので更新なしと判断
                    return false
                } else {
                    if newTime.hasSuffix("時間前") {
                        // お互い〜時間前の場合、辞書順で比較
                        // １日に複数回更新された場合、newTimeの方が値が小さくなる
                        return oldTime > newTime
                    }
                    // oldTimeが〜時間前表記に対して、newTimeが〜秒前、か〜分前の表記になっているということなので、更新があったと判断
                    return true
                }
            } else {
                // 〜分前や〜秒前の場合は前回取得時に通知しているはずなので更新なしと判断
                // 最低数時間おきにしかチェックしないのでここに来ることはありえない想定
                return false
            }
        }
    }
}
