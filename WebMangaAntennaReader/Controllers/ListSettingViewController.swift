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
    
    let comicDao:ComicDao = ComicDao(appDelegate: UIApplication.shared.delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "リストの設定"
        let ud = UserDefaults.standard
        if let listId = ud.string(forKey: Constants.UserDefaultsKeys.LIST_ID) {
            myListIdTextField.text = listId;
        }
        myListIdTextField.becomeFirstResponder()
    }

    @IBAction func openWebMangaAntennaList(_ sender: AnyObject) {
        if let url = URL(string: Constants.WEB_MANGA_ANTENNA_URL + "/list/" + myListIdTextField.text!) {
            UIApplication.shared.openURL(url)
        }
    }

    @IBAction func save(_ sender: AnyObject) {
        let ud = UserDefaults.standard
        let newListId:String = myListIdTextField.text!;
        let oldListId = ud.string(forKey: Constants.UserDefaultsKeys.LIST_ID)
        ud.set(newListId, forKey: Constants.UserDefaultsKeys.LIST_ID)
        if oldListId != newListId {
            comicDao.deleteAll()
        }
        let controllers = navigationController?.viewControllers
        let prev = controllers?[(controllers?.count)! - 2]
        if (prev!.isMember(of: ComicsViewController.self)) {
            
            performSegue(withIdentifier: "unwindComicsFromListSetting", sender: self)
        } else {
            performSegue(withIdentifier: "unwindSettingFromListSetting", sender: self)
        }
    }
}
