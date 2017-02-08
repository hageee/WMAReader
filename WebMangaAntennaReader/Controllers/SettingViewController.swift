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
    fileprivate static let INTERVALS:[Int] = [3, 6, 12, 24]
    fileprivate static let HOUR:Int = 3600
    
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
        let version:String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        versionLabel.text = version
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSyncMethodLabel()
        setUpdateCheckLabelText()
    }
    
    fileprivate func setListURLText() {
        let ud = UserDefaults.standard
        let listId = ud.string(forKey: Constants.UserDefaultsKeys.LIST_ID)
        if listId == nil || listId!.isEmpty {
            listUrl.text = "未設定";
        } else {
            listUrl.text = Constants.WEB_MANGA_ANTENNA_URL + "/list/" + listId!;
        }
    }
    
    fileprivate func setSyncMethodLabel() {
        let ud = UserDefaults.standard
        let syncMethod:Int = ud.integer(forKey: Constants.UserDefaultsKeys.SYNC_METHOD)
        if (syncMethod == Constants.SyncMethods.MY_LIST) {
            syncMethodLabel.text = "マイリスト"
            listCell.isHidden = true
        } else {
            syncMethodLabel.text = "リストURL指定"
            listCell.isHidden = false
            setListURLText()
        }
        self.tableView.reloadData()
    }
    
    fileprivate func setUpdateCheckLabelText() {
        let ud = UserDefaults.standard
        let updateInterval:Int = ud.integer(forKey: Constants.UserDefaultsKeys.UPDATE_CHECK_INTERVAL)
        interval.text = "\(updateInterval)時間毎";
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tappedCell = self.tableView.cellForRow(at: indexPath)
        if (tappedCell == updateCheckCell) {
            showIntervalSelection()
        } else if (tappedCell == syncMethodCell) {
            showSyncMethodSelection()
        } else if (tappedCell == reviewCell) {
            showReview()
        } else if (tappedCell == recommendCell) {
            showRecommendSelection()
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if (cell.isHidden) {
            return 0;
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "unwindComicsFromSetting") {
            let ud = UserDefaults.standard
            let interval = ud.integer(forKey: Constants.UserDefaultsKeys.UPDATE_CHECK_INTERVAL)
            if interval > 0 {
                UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(interval * SettingViewController.HOUR));
                NSLog("Set minimum background fetch interval=\(interval) hours")
            }
        }
    }
    
    fileprivate func showAlertController(_ alertController: UIAlertController) {
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.width / 2.0, y: self.view.bounds.height / 2.0, width: 1.0, height: 1.0)
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func showSyncMethodSelection() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let myListRow = UIAlertAction(title: "マイリスト", style: .default) { action in
            let ud = UserDefaults.standard
            ud.set(Constants.SyncMethods.MY_LIST, forKey: Constants.UserDefaultsKeys.SYNC_METHOD)
            self.setSyncMethodLabel()
        }
        alertController.addAction(myListRow)
        let listRow = UIAlertAction(title: "リストURL指定", style: .default) { action in
            let ud = UserDefaults.standard
            ud.set(Constants.SyncMethods.LIST_URL, forKey: Constants.UserDefaultsKeys.SYNC_METHOD)
            self.setSyncMethodLabel()
        }
        alertController.addAction(listRow)
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        showAlertController(alertController)
    }
    
    fileprivate func showIntervalSelection() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for hour in SettingViewController.INTERVALS {
            let actionRow = UIAlertAction(title: "\(hour)時間毎", style: .default) { action in
                let ud = UserDefaults.standard
                ud.set(hour, forKey: Constants.UserDefaultsKeys.UPDATE_CHECK_INTERVAL)
                UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(hour * SettingViewController.HOUR));
                NSLog("Set minimum background fetch interval=\(hour) hours")
                self.setUpdateCheckLabelText()
            }
            alertController.addAction(actionRow)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        showAlertController(alertController)
    }
    
    fileprivate func showSocialComposeView(_ type:String) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let controller = SLComposeViewController(forServiceType: type)
            
            let link: String = "http://www.apple.com"
            let url = URL(string: link)
            controller?.add(url)
            
            let title: String = "Web漫画の更新をほぼリアルタイムでチェックできる。Web漫画アンテナリーダー"
            controller?.setInitialText(title)
            
            present(controller!, animated: true, completion: {})
        }
    }
    
    fileprivate func showRecommendSelection() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let twitterAction = UIAlertAction(title: "Twitter", style: .default) { action in
            self.showSocialComposeView(SLServiceTypeTwitter)
        }
        let facebookAction = UIAlertAction(title: "Facebook", style: .default) { action in
            self.showSocialComposeView(SLServiceTypeFacebook)
        }
        alertController.addAction(twitterAction)
        alertController.addAction(facebookAction)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        showAlertController(alertController)
    }
    
    fileprivate func showReview() {
        if let url = URL(string:"https://itunes.apple.com/us/app/web-man-huaantenarida/id997210763?l=ja&ls=1&mt=8") {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func unwindSetting(_ seque:UIStoryboardSegue) {
        // Nothing todo
    }
}
