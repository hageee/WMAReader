//
//  WebMangaAntennaReaderUnitTests.swift
//  WebMangaAntennaReaderUnitTests
//
//  Created by Takashi Hagura on 2017/02/12.
//  Copyright © 2017年 Takashi Hagura. All rights reserved.
//

import XCTest
@testable import WebMangaAntennaReader

class BackgroundFetcherTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIsUpdated_DateNewDate() {
        XCTAssertTrue(BackgroudFetcher.isUpdated(oldTime: "2017/01/01", newTime: "2017/01/02"))
    }

    func testIsUpdate_SameDate() {
        XCTAssertFalse(BackgroudFetcher.isUpdated(oldTime: "2017/01/01", newTime: "2017/01/01"))
    }
    
    func testIsUpdated_DateToHour() {
        XCTAssertTrue(BackgroudFetcher.isUpdated(oldTime: "2017/03/03", newTime: "1時間前"))
    }
    
    func testIsUpdated_HourToNewHour() {
        XCTAssertTrue(BackgroudFetcher.isUpdated(oldTime: "9時間前", newTime: "3時間前"))
    }
    
    func testIsUpdated_HourToSameHour() {
        XCTAssertFalse(BackgroudFetcher.isUpdated(oldTime: "9時間前", newTime: "9時間前"))
    }
    
    func testIsUpdated_MinutesToOther() {
        XCTAssertFalse(BackgroudFetcher.isUpdated(oldTime: "50分前", newTime: "3分前"))
    }
    
    func testIsUpdated_HourToDate() {
        XCTAssertFalse(BackgroudFetcher.isUpdated(oldTime: "9時間前", newTime: "2017/01/02"))
    }
}
