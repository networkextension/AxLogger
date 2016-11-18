//
//  ViewController.swift
//  AxLoggerDemo
//
//  Created by 孔祥波 on 18/11/2016.
//  Copyright © 2016 Kong XiangBo. All rights reserved.
//

import UIKit
import Foundation
import AxLogger
class ViewController: UIViewController {

    let  applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.yarshuremac.test" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let ur  = self.applicationDocumentsDirectory.appendingPathComponent("abc")
        print(ur)
        AxLogger.openLogging(ur, date: Date(),debug: true)
        AxLogger.log("test", level: .Debug)
        AxLogger.log("test", level: .Info)
        print(ur,stdout)
        NSLog("lsskdjflsjdflaksdjflkas %")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

