//
//  ComicDao.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/04/07.
//  Copyright (c) 2015年 Takashi Hagura. All rights reserved.
//

import Foundation
import CoreData

public class ComicDao {
    var appDelegate: AppDelegate
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }
    
    func save(remoteComic: RemoteComic) -> Comic? {
        if let managedObjectContext = appDelegate.managedObjectContext {
            var comic: Comic? = findByUrl(remoteComic.url!)
            if comic == nil {
                let managedObject: AnyObject = NSEntityDescription.insertNewObjectForEntityForName("Comic", inManagedObjectContext: managedObjectContext)
                comic = managedObject as? Comic
            }
            let oldUpdatedAt:String? = comic?.valueForKey("updatedAt") as? String
            // エンティティモデルにデータをセット
            comic?.siteName = remoteComic.siteName!
            comic?.siteUrl = remoteComic.siteUrl!
            comic?.thumb = remoteComic.thumb!
            comic?.title = remoteComic.title!
            comic?.updatedAt = remoteComic.date!
            comic?.url = remoteComic.url!
            if oldUpdatedAt == nil || oldUpdatedAt?.hasSuffix("時間前") == true  || oldUpdatedAt >= comic?.updatedAt {
                comic?.willNotify = false
            } else {
                comic?.willNotify = true
            }
            appDelegate.saveContext()
            return comic
        }
        return nil
    }
    
    func save(comic:Comic) {
        if let managedObjectContext = appDelegate.managedObjectContext {
            appDelegate.saveContext()
        }
    }
    
    func findByUrl(url: String) -> Comic? {
        if let context = appDelegate.managedObjectContext {
            let req = NSFetchRequest(entityName: "Comic");
            let entityDiscription = NSEntityDescription.entityForName("Comic", inManagedObjectContext: context);
            req.entity = entityDiscription
            req.predicate = NSPredicate(format: "url = %@", url)
            
            var error: NSError? = nil;
            if let results = context.executeFetchRequest(req, error: &error) {
                if results.count > 0 {
                    return results.first as? Comic
                }
            }
        }
        return nil
    }
    
    func findAll() -> [Comic]? {
        if let managedObjectContext = appDelegate.managedObjectContext {
            let entityDiscription = NSEntityDescription.entityForName("Comic", inManagedObjectContext: managedObjectContext);
            let fetchRequest = NSFetchRequest();
            fetchRequest.entity = entityDiscription;
            var error: NSError? = nil;
            if var results = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [Comic] {
                results.sort(sortByNewer)
                return results
            }
        }
        return [Comic]()
    }
    
    func findWillNotify() -> [Comic]? {
        if let managedObjectContext = appDelegate.managedObjectContext {
            let entityDiscription = NSEntityDescription.entityForName("Comic", inManagedObjectContext: managedObjectContext);
            let req = NSFetchRequest();
            req.entity = entityDiscription;
            req.predicate = NSPredicate(format: "willNotify = %@", NSNumber(bool: true))
            var error: NSError? = nil;
            if var results = managedObjectContext.executeFetchRequest(req, error: &error) as? [Comic] {
                results.sort(sortByNewer)
                return results
            }
        }
        return [Comic]()
    }

    func deleteAll() {
        if let context: NSManagedObjectContext = appDelegate.managedObjectContext {
            let request = NSFetchRequest(entityName: "Comic")
            if let comics:[NSManagedObject] = context.executeFetchRequest(request, error: nil) as? [NSManagedObject] {
                for c in comics {
                    context.deleteObject(c)
                }
            }
            appDelegate.saveContext()
        }
    }

    private func getHour(src: String) -> Int {
        if let hour = src.stringByReplacingOccurrencesOfString("時間前", withString: "", options: nil, range: nil).toInt() {
            return hour
        } else {
            return 0
        }
    }
    
    private func getMinutes(src: String) -> Int {
        if let hour = src.stringByReplacingOccurrencesOfString("分前", withString: "", options: nil, range: nil).toInt() {
            return hour
        } else {
            return 0
        }
    }

    private func sortByNewer(c1:Comic, c2:Comic) -> Bool {
        let updatedAt1:String = c1.updatedAt
        let updatedAt2:String = c2.updatedAt
        if updatedAt1.hasSuffix("分前") {
            if updatedAt2.hasSuffix("時間前") {
                return true
            }
            if updatedAt2.hasSuffix("分前") {
                return getMinutes(updatedAt1) < getMinutes(updatedAt2)
            }
            return true
        }
        if updatedAt1.hasSuffix("時間前") {
            if updatedAt2.hasSuffix("分前") {
                return false
            }
            if updatedAt2.hasSuffix("時間前") {
                return getHour(updatedAt1) < getHour(updatedAt2)
            }
            return true
        }
        if updatedAt2.hasSuffix("分前") || updatedAt2.hasSuffix("時間前") {
            return false
        }
        return updatedAt1 > updatedAt2
    }

}