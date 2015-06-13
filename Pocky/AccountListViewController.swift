//
//  AccountListViewController.swift
//  Pocky
//
//  Created by Hitoshi Saito on 2015/06/12.
//  Copyright (c) 2015年 CyberZ. All rights reserved.
//

import Foundation
import AppKit

class AccountListViewController: NSViewController, NSCollectionViewDelegate {
    
    var hoge: Hoge!
    var hogeArray: NSMutableArray!
    
    @IBOutlet weak var hogeCollectionView: NSCollectionView!
    @IBOutlet var arrayController: NSArrayController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let itemPrototype = self.storyboard?.instantiateControllerWithIdentifier("collectionViewItem")
            as! NSCollectionViewItem
        hogeCollectionView.itemPrototype = itemPrototype
        hoge = Hoge()
        hogeArray = NSMutableArray(array: [hoge, hoge, hoge])
//        hogeCollectionView.content = hogeArray
        
    }
    
}