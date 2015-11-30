//
//  ListSettingController.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/05/14.
//  Copyright (c) 2015年 Takashi Hagura. All rights reserved.
//


import UIKit
import Social

class SettingViewController: UITableViewController {
    private static let INTERVALS:[Int] = [3, 6, 12, 24]
    private static let HOUR:Int = 3600
    
    @IBOutlet weak var syncMethodLabel: UILabel!
    @IBOutlet weak var listUrl: UILabel!
    @IBOutlet weak var interval: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var updateCheckCell: UITableViewCell!
    @IBOutlet weak var syncMethodCell: UITableViewCell!
    @IBOutlet weak var listCell: UITableViewCell!
    @IBOutlet weak var reviewCell: UITableViewCell!
    @IBOutlet weak var recommendCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "設定"
        let version:String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        versionLabel.text = version
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setSyncMethodLabel()
        setUpdateCheckLabelText()
    }
    
    private func setListURLText() {
        let ud = NSUserDefaults.standardUserDefaults()
        let listId = ud.stringForKey(Constants.UserDefaultsKeys.LIST_ID)
        if listId == nil || listId!.isEmpty {
            listUrl.text = "未設定";
        } else {
            listUrl.text = Constants.WEB_MANGA_ANTENNA_URL + "/list/" + listId!;
        }
    }
    
    private func setSyncMethodLabel() {
        let ud = NSUserDefaults.standardUserDefaults()
        let syncMethod:Int = ud.integerForKey(Constants.UserDefaultsKeys.SYNC_METHOD)
        if (syncMethod == Constants.SyncMethods.MY_LIST) {
            syncMethodLabel.text = "マイリスト"
            listCell.hidden = true
        } else {
            syncMethodLabel.text = "リストURL指定"
            listCell.hidden = false
            setListURLText()
        }
        self.tableView.reloadData()
    }
    
    private func setUpdateCheckLabelText() {
        let ud = NSUserDefaults.standardUserDefaults()
        let updateInterval:Int = ud.integerForKey(Constants.UserDefaultsKeys.UPDATE_CHECK_INTERVAL)
        interval.text = "\(updateInterval)時間毎";
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tappedCell = self.tableView.cellForRowAtIndexPath(indexPath)
        if (tappedCell == updateCheckCell) {
            showIntervalSelection()
        } else if (tappedCell == syncMethodCell) {
            showSyncMethodSelection()
        } else if (tappedCell == reviewCell) {
            showReview()
        } else if (tappedCell == recommendCell) {
            showRecommendSelection()
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if (cell.hidden) {
            return 0;
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "unwindComicsFromSetting") {
            let ud = NSUserDefaults.standardUserDefaults()
            let interval = ud.integerForKey(Constants.UserDefaultsKeys.UPDATE_CHECK_INTERVAL)
            if interval > 0 {
                UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(NSTimeInterval(interval * SettingViewController.HOUR));
                NSLog("Set minimum background fetch interval=\(interval) hours")
            }
        }
    }
    
    private func showAlertController(alertController: UIAlertController) {
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.width / 2.0, self.view.bounds.height / 2.0, 1.0, 1.0)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func showSyncMethodSelection() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let myListRow = UIAlertAction(title: "マイリスト", style: .Default) { action in
            let ud = NSUserDefaults.standardUserDefaults()
            ud.setObject(Constants.SyncMethods.MY_LIST, forKey: Constants.UserDefaultsKeys.SYNC_METHOD)
            self.setSyncMethodLabel()
        }
        alertController.addAction(myListRow)
        let listRow = UIAlertAction(title: "リストURL指定", style: .Default) { action in
            let ud = NSUserDefaults.standardUserDefaults()
            ud.setObject(Constants.SyncMethods.LIST_URL, forKey: Constants.UserDefaultsKeys.SYNC_METHOD)
            self.setSyncMethodLabel()
        }
        alertController.addAction(listRow)
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        showAlertController(alertController)
    }
    
    private func showIntervalSelection() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        for hour in SettingViewController.INTERVALS {
            let actionRow = UIAlertAction(title: "\(hour)時間毎", style: .Default) { action in
                let ud = NSUserDefaults.standardUserDefaults()
                ud.setObject(hour, forKey: Constants.UserDefaultsKeys.UPDATE_CHECK_INTERVAL)
                UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(NSTimeInterval(hour * SettingViewController.HOUR));
                NSLog("Set minimum background fetch interval=\(hour) hours")
                self.setUpdateCheckLabelText()
            }
            alertController.addAction(actionRow)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        showAlertController(alertController)
    }
    
    private func showSocialComposeView(type:String) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            let controller = SLComposeViewController(forServiceType: type)
            
            let link: String = "http://www.apple.com"
            let url = NSURL(string: link)
            controller.addURL(url)
            
            let title: String = "Web漫画の更新をほぼリアルタイムでチェックできる。Web漫画アンテナリーダー"
            controller.setInitialText(title)
            
            presentViewController(controller, animated: true, completion: {})
        }
    }
    
    private func showRecommendSelection() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let twitterAction = UIAlertAction(title: "Twitter", style: .Default) { action in
            self.showSocialComposeView(SLServiceTypeTwitter)
        }
        let facebookAction = UIAlertAction(title: "Facebook", style: .Default) { action in
            self.showSocialComposeView(SLServiceTypeFacebook)
        }
        alertController.addAction(twitterAction)
        alertController.addAction(facebookAction)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        showAlertController(alertController)
    }
    
    private func showReview() {
        if let url = NSURL(string:"https://itunes.apple.com/us/app/web-man-huaantenarida/id997210763?l=ja&ls=1&mt=8") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func unwindSetting(seque:UIStoryboardSegue) {
        // Nothing todo
    }
}
