//
//  ViewController.swift
//  Okashi
//
//  Created by Yusuke Nakane on 2018/11/20.
//  Copyright © 2018 usayama. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // サーチバーのデリゲート通知先を設定
        searchText.delegate = self
        // 入力のヒントになるプレースホルダーを設定
        searchText.placeholder = "お菓子の名前を入力してください"
    }

    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
}

