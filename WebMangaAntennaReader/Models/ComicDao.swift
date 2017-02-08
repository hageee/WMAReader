//
//  ComicDao.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/04/07.
//  Copyright (c) 2015年 Takashi Hagura. All rights reserved.
//

import Foundation
import CoreData

open class ComicDao {
    var appDelegate: AppDelegate
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }
    
    func save(_ remoteComic: RemoteComic) -> Comic? {
        if let managedObjectContext = appDelegate.managedObjectContext {
            var comic: Comic? = findByUrl(remoteComic.url!)
            if comic == nil {
                let managedObject: AnyObject = NSEntityDescription.insertNewObject(forEntityName: "Comic", into: managedObjectContext)
                comic = managedObject as? Comic
            }
            // エンティティモデルにデータをセット
            comic?.siteName = remoteComic.siteName!
            comic?.siteUrl = remoteComic.siteUrl!
            comic?.thumb = remoteComic.thumb!
            comic?.title = remoteComic.title!
            comic?.updatedAt = remoteComic.date!
            comic?.url = remoteComic.url!
            comic?.willNotify = false
            appDelegate.saveContext()
            return comic
        }
        return nil
    }
    
    func save(_ comic:Comic) {
        if let _ = appDelegate.managedObjectContext {
            appDelegate.saveContext()
        }
    }
    
    func findByUrl(_ url: String) -> Comic? {
        if let context = appDelegate.managedObjectContext {
            let req = NSFetchRequest<NSFetchRequestResult>(entityName: "Comic");
            let entityDiscription = NSEntityDescription.entity(forEntityName: "Comic", in: context);
            req.entity = entityDiscription
            req.predicate = NSPredicate(format: "url = %@", url)
            
            do {
                let results = try context.fetch(req)
                if results.count > 0 {
                    return results.first as? Comic
                }
            } catch let error as NSError {
                NSLog("%@ %@", error, error.userInfo)
            }
        }
        return nil
    }
    
    func findAll() -> [Comic]? {
        if let managedObjectContext = appDelegate.managedObjectContext {
            let entityDiscription = NSEntityDescription.entity(forEntityName: "Comic", in: managedObjectContext);
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>();
            fetchRequest.entity = entityDiscription;
            do {
                if var results = try managedObjectContext.fetch(fetchRequest) as? [Comic] {
                    results.sort(by: sortByNewer)
                    return results
                }
            } catch let error as NSError {
                NSLog("%@ %@", error, error.userInfo)
            }
        }
        return [Comic]()
    }

    func deleteAll() {
        if let context: NSManagedObjectContext = appDelegate.managedObjectContext {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Comic")
            if let comics:[NSManagedObject] = (try? context.fetch(request)) as? [NSManagedObject] {
                for c in comics {
                    context.delete(c)
                }
            }
            appDelegate.saveContext()
        }
    }

    fileprivate func getHour(_ src: String) -> Int {
        if let hour = Int(src.replacingOccurrences(of: "時間前", with: "", options: [], range: nil)) {
            return hour
        } else {
            return 0
        }
    }
    
    fileprivate func getMinutes(_ src: String) -> Int {
        if let hour = Int(src.replacingOccurrences(of: "分前", with: "", options: [], range: nil)) {
            return hour
        } else {
            return 0
        }
    }

    fileprivate func sortByNewer(_ c1:Comic, c2:Comic) -> Bool {
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
