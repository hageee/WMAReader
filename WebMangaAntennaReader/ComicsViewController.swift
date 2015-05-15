//
//  ViewController.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/01/07.
//  Copyright (c) 2015年 Takashi Hagura. All rights reserved.
//

import UIKit

class ComicsViewController: UITableViewController, NSURLConnectionDelegate {
    let HOUR = 3600
    let BACKGROUND_FETCH_INTERBAL_DEFAULT:Int = 6
    
    private var comics: [Comic] = []
    private var imageCache:Dictionary<String, UIImage>  = Dictionary()
    
    let comicDao:ComicDao = ComicDao(appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Web漫画アンテナリーダー"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: Constants.Notifications.UPDATE_COMIC, object: nil)
        self.refreshControl?.addTarget(self, action: "reload", forControlEvents: UIControlEvents.ValueChanged)
        self.comics = self.comicDao.findAll()!
        self.reload()
    }
    
    private func currentMyListId() -> String? {
        let ud = NSUserDefaults.standardUserDefaults()
        return ud.stringForKey(Constants.UserDefaultsKeys.MY_LIST_ID)
    }

    func reload() {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0;
        let ud = NSUserDefaults.standardUserDefaults()
        if let myListId:String = currentMyListId() {
            NSLog("Load list: %@",myListId)
            RemoteComic.fetch(forList: myListId) { (remoteComics, error, local) -> Void in
                if remoteComics.count > 0 {
                    let q_global: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    let q_main: dispatch_queue_t  = dispatch_get_main_queue();
                    dispatch_async(q_global, {
                        for remoteComic in remoteComics {
                            self.comicDao.save(remoteComic)
                        }
                        self.comics = self.comicDao.findAll()!
                        dispatch_async(q_main, {
                            self.tableView.reloadData()
                            self.refreshControl?.endRefreshing()
                        })
                    })
                } else {
                    self.showListAlert("エラー", message: "漫画の更新情報が取得できませんでした。ネットワークに繋がっていないか、リストのURLが無効な可能性があります。リストのURLをご確認ください。")
                }
            }
        } else {
            self.showListAlert("初期設定をお願いします", message: "Web漫画アンテナリーダーをお使いいただくには、Web漫画アンテナで作成したリストURLの設定が必要です。")
        }
    }

    private func showListAlert(title:String?, message: String?) {
        self.refreshControl?.endRefreshing()
        var alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { action in
            self.performSegueWithIdentifier(Constants.Seques.SHOW_INIT, sender: self)
        }
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)        
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let c : Int = self.comics.count
        return c
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ComicCell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as! ComicCell
        let comic: Comic = self.comics[indexPath.row] as Comic

        var imageUrl: String? = comic.valueForKey("thumb") as? String
        cell.titleLabel.text = comic.valueForKey("title") as? String
        cell.updateTimeLabel.text = comic.valueForKey("updatedAt") as? String
        cell.siteNameLabel.text = comic.valueForKey("siteName") as? String
        cell.comicImageView.image = nil
        
        var q_global: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        var q_main: dispatch_queue_t  = dispatch_get_main_queue();
        
        dispatch_async(q_global, {
            if let href = imageUrl {
                var image = self.imageCache[href]
                if image == nil {
                    let imageURL: NSURL = NSURL(string: href)!
                    let imageData: NSData = NSData(contentsOfURL: imageURL)!
                    image = UIImage(data: imageData)!
                    self.imageCache[href] = image
                }
                dispatch_async(q_main, {
                    cell.comicImageView.image = image;
                    cell.layoutSubviews()
                })
            }
        })
        return cell;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let comic: Comic = self.comics[indexPath.row] as Comic!
        self.performSegueWithIdentifier(Constants.Seques.SHOW_WEB_SITE, sender: self)
    }
    
    @IBAction func reloadBtnTouched(sender : AnyObject) {
        self.reload()
        self.tableView.scrollRectToVisible(CGRect(x:0 , y: 0, width: 1,height:1), animated: true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == Constants.Seques.SHOW_WEB_SITE) {
            if let row:NSIndexPath = self.tableView.indexPathForSelectedRow() {
                let comic: Comic = self.comics[row.row] as Comic
                let webView:WebViewController = segue.destinationViewController as! WebViewController
                webView.comic = comic
            }
        }
    }
    
    @IBAction func applySettings(seque:UIStoryboardSegue) {
        reload()
        let application = UIApplication.sharedApplication()
        let settings = UIUserNotificationSettings(
            forTypes: UIUserNotificationType.Badge
                | UIUserNotificationType.Sound
                | UIUserNotificationType.Alert,
            categories: nil)
        application.registerUserNotificationSettings(settings);
        let ud = NSUserDefaults.standardUserDefaults()
        var interval = ud.integerForKey(Constants.UserDefaultsKeys.UPDATE_CHECK_INTERVAL)
        if interval <= 0 {
            interval = BACKGROUND_FETCH_INTERBAL_DEFAULT;
            ud.setObject(interval, forKey: Constants.UserDefaultsKeys.UPDATE_CHECK_INTERVAL)
        }
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(NSTimeInterval(interval * HOUR));
    }
}
