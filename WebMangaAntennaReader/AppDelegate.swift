//
//  AppDelegate.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/01/07.
//  Copyright (c) 2015年 Takashi Hagura. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let ud = UserDefaults.standard
        let listId = ud.string(forKey: Constants.UserDefaultsKeys.LIST_ID)
        let interval = ud.integer(forKey: Constants.UserDefaultsKeys.UPDATE_CHECK_INTERVAL)
        let syncMethod = ud.integer(forKey: Constants.UserDefaultsKeys.SYNC_METHOD)
        NSLog("ApplicationDidFinishLaunchingWithOptions: options=\(launchOptions), listID=\(listId), syncMethod=\(syncMethod), updateInterval=\(interval)")
        initSyncMethod()
        initBackgroundFetchInterval()
        CookiePersistanceManager.sharedInstance.loadCookie()
        return true
    }
    
    fileprivate func initSyncMethod() {
        let ud = UserDefaults.standard
        let listId = ud.string(forKey: Constants.UserDefaultsKeys.LIST_ID)
        let syncMethod = ud.integer(forKey: Constants.UserDefaultsKeys.SYNC_METHOD)
        if (syncMethod == 0) {
            if (listId != nil) {
                ud.set(Constants.SyncMethods.LIST_URL, forKey: Constants.UserDefaultsKeys.SYNC_METHOD)
            } else {
                ud.set(Constants.SyncMethods.MY_LIST, forKey: Constants.UserDefaultsKeys.SYNC_METHOD)
            }
        }
    }
    
    fileprivate func initBackgroundFetchInterval() {
        let ud = UserDefaults.standard
        var interval = ud.integer(forKey: Constants.UserDefaultsKeys.UPDATE_CHECK_INTERVAL)
        if interval <= 0 {
            interval = Constants.BACKGROUND_FETCH_INTERBAL_DEFAULT
            ud.set(Constants.BACKGROUND_FETCH_INTERBAL_DEFAULT, forKey: Constants.UserDefaultsKeys.UPDATE_CHECK_INTERVAL)
        }
        UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(interval * 60 * 60));
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        let notification = Notification(name: Notification.Name(rawValue: Constants.Notifications.UPDATE_COMIC), object: nil)
        NotificationCenter.default.post(notification)
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        BackgroudFetcher.init(completionHandler: completionHandler).start()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        CookiePersistanceManager.sharedInstance.saveCookie()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CookiePersistanceManager.sharedInstance.saveCookie()
        self.saveContext()
    }

    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "net.takashi8.TestCoreDate" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] 
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "WebMangaAntennaReader", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("TestCoreDate.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }

}

