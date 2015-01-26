//
//  Comic.swift
//  WebMangaAntennaReader
//
//  Created by Takashi Hagura on 2015/04/07.
//  Copyright (c) 2015年 Takashi Hagura. All rights reserved.
//

import Foundation
import CoreData

class Comic: NSManagedObject {

    @NSManaged var siteName: String
    @NSManaged var siteUrl: String
    @NSManaged var thumb: String
    @NSManaged var title: String
    @NSManaged var updatedAt: String
    @NSManaged var url: String
    @NSManaged var willNotify: Bool

}
