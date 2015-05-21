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
    
    @IBOutlet weak var listUrl: UILabel!
    @IBOutlet weak var interval: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var updateCheckCell: UITableViewCell!
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
        let ud = NSUserDefaults.standardUserDefaults()
        if let myListId:String = ud.stringForKey(Constants.UserDefaultsKeys.MY_LIST_ID) {
            listUrl.text = Constants.WEB_MANGA_ANTENNA_URL + "list/" + myListId;
        } else {
            listUrl.text = "未設定";
        }
        setUpdateCheckLabelText()
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
        } else if (tappedCell == reviewCell) {
            showReview()
        } else if (tappedCell == recommendCell) {
            showRecommendSelection()
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    private func showIntervalSelection() {
        var alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        for hour in SettingViewController.INTERVALS {
            let actionRow = UIAlertAction(title: "\(hour)時間毎", style: .Default) { action in
                let ud = NSUserDefaults.standardUserDefaults()
                ud.setObject(hour, forKey: Constants.UserDefaultsKeys.UPDATE_CHECK_INTERVAL)
                self.setUpdateCheckLabelText()
                NSLog("Set update interval every %d hour", hour)
            }
            alertController.addAction(actionRow)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        // For iPad
        if let popoverController = alertController.popoverPresentationController {
            alertController.popoverPresentationController?.sourceView = self.view
            let frame = UIScreen.mainScreen().applicationFrame
            alertController.popoverPresentationController?.sourceRect = CGRectMake(CGRectGetMidX(frame) - 90, updateCheckCell.frame.origin.x + 70, 120, 50)
        }
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func showSocialComposeView(type:String) {
        // availability check
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            // make controller to share on twitter
            var controller = SLComposeViewController(forServiceType: type)
            
            // add link to the controller
            let link: String = "http://www.apple.com"
            let url = NSURL(string: link)
            controller.addURL(url)
            
            // add text to the controller
            let title: String = "Web漫画の更新をほぼリアルタイムでチェックできる。Web漫画アンテナリーダー"
            controller.setInitialText(title)
            
            // show twitter post screen
            presentViewController(controller, animated: true, completion: {})
        }
    }
    
    private func showRecommendSelection() {
        var alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
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
        
        // For iPad
        if let popoverController = alertController.popoverPresentationController {
            alertController.popoverPresentationController?.sourceView = self.view
            alertController.popoverPresentationController?.sourceRect = CGRectMake(100.0, 100.0, 20.0, 20.0);
        }

        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func showReview() {
        if let url = NSURL(string:"https://itunes.apple.com/us/app/web-man-huaantenarida/id997210763?l=ja&ls=1&mt=8") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}
