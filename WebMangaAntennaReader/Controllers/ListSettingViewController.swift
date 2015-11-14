//
//  SettingViewCntroller.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/04/16.
//  Copyright (c) 2015年 Takashi Hagura. All rights reserved.
//

import UIKit
import SafariServices

class ListSettingViewController: UIViewController {
    @IBOutlet weak var myListIdTextField: UITextField!
    @IBOutlet weak var listOpenButton: UIButton!
    
    let comicDao:ComicDao = ComicDao(appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "リストの設定"
        let ud = NSUserDefaults.standardUserDefaults()
        if let listId = ud.stringForKey(Constants.UserDefaultsKeys.LIST_ID) {
            myListIdTextField.text = listId;
        }
        myListIdTextField.becomeFirstResponder()
    }

    @IBAction func openWebMangaAntennaList(sender: AnyObject) {
        if let url = NSURL(string: Constants.WEB_MANGA_ANTENNA_URL + "/list" + myListIdTextField.text!) {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    @IBAction func save(sender: AnyObject) {
        let ud = NSUserDefaults.standardUserDefaults()
        let newListId:String = myListIdTextField.text!;
        let oldListId = ud.stringForKey(Constants.UserDefaultsKeys.LIST_ID)
        ud.setObject(newListId, forKey: Constants.UserDefaultsKeys.LIST_ID)
        if oldListId != newListId {
            comicDao.deleteAll()
        }
        let controllers = navigationController?.viewControllers
        let prev = controllers?[(controllers?.count)! - 2]
        if (prev!.isMemberOfClass(ComicsViewController.self)) {
            
            performSegueWithIdentifier("unwindComicsFromListSetting", sender: self)
        } else {
            performSegueWithIdentifier("unwindSettingFromListSetting", sender: self)
        }
    }
}