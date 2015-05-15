//
//  SettingViewCntroller.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/04/16.
//  Copyright (c) 2015年 Takashi Hagura. All rights reserved.
//

import UIKit

class ListSettingViewController: UIViewController {
    @IBOutlet weak var myListIdTextField: UITextField!
    
    let comicDao:ComicDao = ComicDao(appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let ud = NSUserDefaults.standardUserDefaults()
        if let myListId:String = ud.stringForKey(Constants.UserDefaultsKeys.MY_LIST_ID) {
            myListIdTextField.text = myListId;
        }
        myListIdTextField.becomeFirstResponder()
    }

    @IBAction func hideKeyboard(sender: AnyObject) {
        myListIdTextField.resignFirstResponder()
    }

    @IBAction func openWebMangaAntenna(sender: AnyObject) {
        if let url = NSURL(string: Constants.WEB_MANGA_ANTENNA_URL) {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == Constants.Seques.UNWIND_LIST_SETTING) {
            let ud = NSUserDefaults.standardUserDefaults()
            let newListId:String = myListIdTextField.text;
            let oldListId = ud.stringForKey(Constants.UserDefaultsKeys.MY_LIST_ID)
            ud.setObject(newListId, forKey: Constants.UserDefaultsKeys.MY_LIST_ID)
            if oldListId != newListId {
                comicDao.deleteAll()
            }
        }
    }

}