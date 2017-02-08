//
//  ViewController.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/01/07.
//  Copyright (c) 2015年 Takashi Hagura. All rights reserved.
//

import UIKit
import CMPopTipView
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ComicsViewController: UITableViewController, NSURLConnectionDelegate {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    fileprivate var comics: [Comic] = []
    fileprivate var imageCache:Dictionary<String, UIImage>  = Dictionary()
    fileprivate var popupView:CMPopTipView? = nil
    let comicDao:ComicDao = ComicDao(appDelegate: UIApplication.shared.delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ComicsViewController.reload), name: NSNotification.Name(rawValue: Constants.Notifications.UPDATE_COMIC), object: nil)
        self.refreshControl?.addTarget(self, action: #selector(ComicsViewController.reload), for: UIControlEvents.valueChanged)
        load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPath, animated: false)
        }
        self.editButton.isEnabled = (currentSyncMethod() == Constants.SyncMethods.MY_LIST)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        hideSuggestion()
        super.viewWillAppear(animated)
    }
    
    fileprivate func currentMyListId() -> String {
        if let listId = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.LIST_ID) {
            return listId
        }
        return ""
    }
    
    fileprivate func currentSyncMethod() -> Int? {
        return UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.SYNC_METHOD)
    }
    
    fileprivate func initPopupView() {
        popupView = CMPopTipView()
        // popup.delegate = self;
        popupView?.textAlignment = NSTextAlignment.left
        popupView?.backgroundColor = UIColor(red: 0, green: 183 / 255, blue: 238 / 255, alpha: 0.9);
        popupView?.borderWidth = 0;
        popupView?.has3DStyle = false
        popupView?.hasGradientBackground = false
    }
    
    fileprivate func showSuggestion() {
        if popupView == nil {
            initPopupView()
        }
        popupView?.message = "編集ボタンを押してWeb漫画アンテナのマイリストを作成しましょう。\nアプリで更新をチェックできるようになります。"
        popupView?.presentPointing(at: editButton, animated:true);
    }
    
    fileprivate func hideSuggestion() {
        popupView?.dismiss(animated: true)
    }
    
    fileprivate func load() {
        let globalQueue: DispatchQueue = DispatchQueue.global(qos: .background);
        let mainQueue: DispatchQueue  = DispatchQueue.main;
        globalQueue.async(execute: {
            self.comics = self.comicDao.findAll()!
            mainQueue.async(execute: {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                if (self.currentSyncMethod() == Constants.SyncMethods.MY_LIST && self.comics.count == 0) {
                    self.showSuggestion()
                }
            })
        })
    }
    
    func reload() {
        UIApplication.shared.applicationIconBadgeNumber = 0;
        if (Constants.SyncMethods.LIST_URL == currentSyncMethod()) {
            RemoteComic.fetch(forList: currentMyListId(), completion: fetchCompletationCallbak)
        } else {
            RemoteComic.fetchBookmark(fetchCompletationCallbak)
        }
    }
    
    fileprivate func fetchCompletationCallbak(_ remoteComics: [RemoteComic]?, _ error: Fetcher.ResponseError?, _ local: Bool) -> Void {
        NSLog("Start fetchCompletationCallbak")
        if remoteComics?.count > 0 {
            let q_global: DispatchQueue = DispatchQueue.global(qos: .background);
            q_global.async(execute: {
                for remoteComic in remoteComics ?? [] {
                    let _ = self.comicDao.save(remoteComic)
                }
                self.load()
                NSLog("Finish fetchCompletationCallbak")
            })
            initNotificationSettings()
        } else {
            DispatchQueue.main.async(execute: {
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
    
    fileprivate func initNotificationSettings() {
        let settings = UIUserNotificationSettings(
            types: [UIUserNotificationType.badge, UIUserNotificationType.sound, UIUserNotificationType.alert],
            categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings);
    }
    
    fileprivate func showListAlert(_ title:String?, message: String?) {
        self.refreshControl?.endRefreshing()
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { action in
            self.performSegue(withIdentifier: Constants.Seques.SHOW_INIT, sender: self)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    fileprivate func showAlert(_ title:String?, message: String?) {
        self.refreshControl?.endRefreshing()
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let c : Int = self.comics.count
        return c
    }
    
    fileprivate func getImageFromHref(_ href:String) -> UIImage? {
        if let imageURL = URL(string: href) {
            if let imageData = try? Data(contentsOf: imageURL) {
                return UIImage(data: imageData)
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ComicCell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as! ComicCell
        let comic: Comic = self.comics[indexPath.row] as Comic

        let imageUrl: String? = comic.value(forKey: "thumb") as? String
        cell.titleLabel.text = comic.value(forKey: "title") as? String
        cell.updateTimeLabel.text = comic.value(forKey: "updatedAt") as? String
        cell.siteNameLabel.text = comic.value(forKey: "siteName") as? String
        cell.comicImageView.image = nil
        
        let q_global: DispatchQueue = DispatchQueue.global(qos: .background);
        let q_main: DispatchQueue  = DispatchQueue.main;
        
        q_global.async(execute: {
            if let href = imageUrl {
                var image = self.imageCache[href]
                if image == nil {
                    if let _image = self.getImageFromHref(href) {
                        image = _image
                        self.imageCache[href] = image
                    }
                }
                if image != nil {
                    q_main.async(execute: {
                        cell.comicImageView.image = image;
                        cell.layoutSubviews()
                    })
                }
            }
        })
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: Constants.Seques.SHOW_WEB_SITE, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == Constants.Seques.SHOW_WEB_SITE) {
            if let row:IndexPath = self.tableView.indexPathForSelectedRow {
                let comic: Comic = self.comics[row.row] as Comic
                let webViewController = segue.destination as! WebViewController
                webViewController.url = comic.url
                webViewController.title = comic.title
            }
        } else if (segue.identifier == Constants.Seques.SHOW_WEB_EDIT) {
            let nav = segue.destination as! UINavigationController
            let webViewController = nav.topViewController as! WebViewController
            webViewController.url = Constants.WEB_MANGA_ANTENNA_URL + "/bookmark"
        }
    }
    
    @IBAction func unwindComicsWithReload(_ seque:UIStoryboardSegue) {
        reload()
    }
    
    @IBAction func unwindComicsWithReset(_ seque:UIStoryboardSegue) {
        comicDao.deleteAll()
        reload()
    }
    
}
