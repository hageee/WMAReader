//
//  ViewController.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/01/07.
//  Copyright (c) 2015年 Takashi Hagura. All rights reserved.
//

import UIKit

class ComicsViewController: UITableViewController, NSURLConnectionDelegate {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    private var comics: [Comic] = []
    private var imageCache:Dictionary<String, UIImage>  = Dictionary()
    
    let comicDao:ComicDao = ComicDao(appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Web漫画アンテナリーダー"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: Constants.Notifications.UPDATE_COMIC, object: nil)
        self.refreshControl?.addTarget(self, action: "reload", forControlEvents: UIControlEvents.ValueChanged)
        reload()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
        self.editButton.enabled = (currentSyncMethod() == Constants.SyncMethods.MY_LIST)
    }
    
    private func currentMyListId() -> String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(Constants.UserDefaultsKeys.LIST_ID)
    }
    
    private func currentSyncMethod() -> Int? {
        return NSUserDefaults.standardUserDefaults().integerForKey(Constants.UserDefaultsKeys.SYNC_METHOD)
    }

    func reload() {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0;
        if (Constants.SyncMethods.LIST_URL == currentSyncMethod()) {
            if let listId:String = currentMyListId() {
                RemoteComic.fetch(forList: listId, completion: fetchCompletationCallbak)
            }
        } else {
            RemoteComic.fetchBookmark(fetchCompletationCallbak)
        }
    }
    
    private func fetchCompletationCallbak(remoteComics: [RemoteComic]!, error: Fetcher.ResponseError!, local: Bool) -> Void {
        if remoteComics?.count > 0 {
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
            dispatch_async(dispatch_get_main_queue(), {
                if (Constants.SyncMethods.LIST_URL == self.currentSyncMethod()) {
                    self.showListAlert("エラー", message: "漫画の更新情報が取得できませんでした。ネットワークに繋がっていないか、リストのURLが無効な可能性があります。リストのURLをご確認ください。")
                } else {
                    self.showAlert("エラー", message: "漫画の更新情報が取得できませんでした。ネットワークに繋がっていないか、マイリストに漫画が登録されていない可能性があります。編集ボタンからマイリストを開いてご確認ください。")
                }
            })
        }
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
        self.performSegueWithIdentifier(Constants.Seques.SHOW_WEB_SITE, sender: self)
    }
    
    @IBAction func reloadBtnTouched(sender : AnyObject) {
        self.reload()
        self.tableView.scrollRectToVisible(CGRect(x:0 , y: 0, width: 1,height:1), animated: true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == Constants.Seques.SHOW_WEB_SITE) {
            if let row:NSIndexPath = self.tableView.indexPathForSelectedRow {
                let comic: Comic = self.comics[row.row] as Comic
                let webView:WebViewController = segue.destinationViewController as! WebViewController
                webView.comic = comic
            }
        } else if (segue.identifier == Constants.Seques.SHOW_WEB_EDIT) {
            let webView:WebEditController = segue.destinationViewController as! WebEditController
            webView.url = Constants.WEB_MANGA_ANTENNA_URL + "/bookmark"
        }
    }
    
    @IBAction func unwindWithReload(seque:UIStoryboardSegue) {
        reload()
    }
    
    @IBAction func unwindWithReset(seque:UIStoryboardSegue) {
        comicDao.deleteAll()
        reload()
    }
    
}
