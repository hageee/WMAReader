//
//  ComicCell.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/01/07.
//  Copyright (c) 2015年 Takashi Hagura. All rights reserved.
//

import UIKit

class ComicCell: UITableViewCell {

    @IBOutlet weak var comicImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.8)
    }
}