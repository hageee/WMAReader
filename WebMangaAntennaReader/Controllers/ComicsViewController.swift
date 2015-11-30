//
//  ViewController.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/01/07.
//  Copyright (c) 2015年 Takashi Hagura. All rights reserved.
//

import UIKit
import CMPopTipView

class ComicsViewController: UITableViewController, NSURLConnectionDelegate {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    private var comics: [Comic] = []
    private var imageCache:Dictionary<String, UIImage>  = Dictionary()
    private var popupView:CMPopTipView? = nil
    let comicDao:ComicDao = ComicDao(appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: Constants.Notifications.UPDATE_COMIC, object: nil)
        self.refreshControl?.addTarget(self, action: "reload", forControlEvents: UIControlEvents.ValueChanged)
        load()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
        self.editButton.enabled = (currentSyncMethod() == Constants.SyncMethods.MY_LIST)
    }
    
    override func viewWillDisappear(animated: Bool) {
        hideSuggestion()
        super.viewWillAppear(animated)
    }
    
    private func currentMyListId() -> String {
        if let listId = NSUserDefaults.standardUserDefaults().stringForKey(Constants.UserDefaultsKeys.LIST_ID) {
            return listId
        }
        return ""
    }
    
    private func currentSyncMethod() -> Int? {
        return NSUserDefaults.standardUserDefaults().integerForKey(Constants.UserDefaultsKeys.SYNC_METHOD)
    }
    
    private func initPopupView() {
        popupView = CMPopTipView()
        // popup.delegate = self;
        popupView?.textAlignment = NSTextAlignment.Left
        popupView?.backgroundColor = UIColor(red: 0, green: 183 / 255, blue: 238 / 255, alpha: 0.9);
        popupView?.borderWidth = 0;
        popupView?.has3DStyle = false
        popupView?.hasGradientBackground = false
    }
    
    private func showSuggestion() {
        if popupView == nil {
            initPopupView()
        }
        popupView?.message = "編集ボタンを押してWeb漫画アンテナリーダーのマイリストを作成しましょう。\nアプリで更新をチェックできるようになります。"
        popupView?.presentPointingAtBarButtonItem(editButton, animated:true);
    }
    
    private func hideSuggestion() {
        popupView?.dismissAnimated(true)
    }
    
    private func load() {
        let globalQueue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        let mainQueue: dispatch_queue_t  = dispatch_get_main_queue();
        dispatch_async(globalQueue, {
            self.comics = self.comicDao.findAll()!
            dispatch_async(mainQueue, {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                if (self.currentSyncMethod() == Constants.SyncMethods.MY_LIST && self.comics.count == 0) {
                    self.showSuggestion()
                }
            })
        })
    }
    
    func reload() {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0;
        if (Constants.SyncMethods.LIST_URL == currentSyncMethod()) {
            RemoteComic.fetch(forList: currentMyListId(), completion: fetchCompletationCallbak)
        } else {
            RemoteComic.fetchBookmark(fetchCompletationCallbak)
        }
    }
    
    private func fetchCompletationCallbak(remoteComics: [RemoteComic]!, error: Fetcher.ResponseError!, local: Bool) -> Void {
        NSLog("Start fetchCompletationCallbak")
        if remoteComics?.count > 0 {
            let q_global: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(q_global, {
                for remoteComic in remoteComics {
                    self.comicDao.save(remoteComic)
                }
                self.load()
                NSLog("Finish fetchCompletationCallbak")
            })
            initNotificationSettings()
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                if (Constants.SyncMethods.LIST_URL == self.currentSyncMethod()) {
                    self.showListAlert("エラー", message: "漫画の更新情報が取得できませんでした。ネットワークに繋がっていないか、リストのURLが無効な可能性があります。リストのURLをご確認ください。")
                } else {
                    self.showAlert("エラー", message: "漫画の更新情報が取得できませんでした。ネットワークに繋がっていないか、マイリストに漫画が登録されていない可能性があります。編集ボタンからマイリストを開いてご確認ください。")
                }
                self.load()
                NSLog("Finish fetchCompletationCallbak with error")
            })
        }
    }
    
    private func initNotificationSettings() {
        let settings = UIUserNotificationSettings(
            forTypes: [UIUserNotificationType.Badge, UIUserNotificationType.Sound, UIUserNotificationType.Alert],
            categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings);
    }
    
    private func showListAlert(title:String?, message: String?) {
        self.refreshControl?.endRefreshing()
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { action in
            self.performSegueWithIdentifier(Constants.Seques.SHOW_INIT, sender: self)
        }
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    private func showAlert(title:String?, message: String?) {
        self.refreshControl?.endRefreshing()
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let c : Int = self.comics.count
        return c
    }
    
    private func getImageFromHref(href:String) -> UIImage? {
        if let imageURL = NSURL(string: href) {
            if let imageData = NSData(contentsOfURL: imageURL) {
                return UIImage(data: imageData)
            }
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ComicCell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as! ComicCell
        let comic: Comic = self.comics[indexPath.row] as Comic

        let imageUrl: String? = comic.valueForKey("thumb") as? String
        cell.titleLabel.text = comic.valueForKey("title") as? String
        cell.updateTimeLabel.text = comic.valueForKey("updatedAt") as? String
        cell.siteNameLabel.text = comic.valueForKey("siteName") as? String
        cell.comicImageView.image = nil
        
        let q_global: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        let q_main: dispatch_queue_t  = dispatch_get_main_queue();
        
        dispatch_async(q_global, {
            if let href = imageUrl {
                var image = self.imageCache[href]
                if image == nil {
                    if let _image = self.getImageFromHref(href) {
                        image = _image
                        self.imageCache[href] = image
                    }
                }
                if image != nil {
                    dispatch_async(q_main, {
                        cell.comicImageView.image = image;
                        cell.layoutSubviews()
                    })
                }
            }
        })
        return cell;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(Constants.Seques.SHOW_WEB_SITE, sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == Constants.Seques.SHOW_WEB_SITE) {
            if let row:NSIndexPath = self.tableView.indexPathForSelectedRow {
                let comic: Comic = self.comics[row.row] as Comic
                let webViewController = segue.destinationViewController as! WebViewController
                webViewController.url = comic.url
                webViewController.title = comic.title
            }
        } else if (segue.identifier == Constants.Seques.SHOW_WEB_EDIT) {
            let nav = segue.destinationViewController as! UINavigationController
            let webViewController = nav.topViewController as! WebViewController
            webViewController.url = Constants.WEB_MANGA_ANTENNA_URL + "/bookmark"
        }
    }
    
    @IBAction func unwindComicsWithReload(seque:UIStoryboardSegue) {
        reload()
    }
    
    @IBAction func unwindComicsWithReset(seque:UIStoryboardSegue) {
        comicDao.deleteAll()
        reload()
    }
    
}
