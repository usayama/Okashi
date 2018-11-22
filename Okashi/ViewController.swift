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
    
    // 検索ボタンをクリック（タップ）時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // キーボードを閉じる
        view.endEditing(true)
        // サーチバーにテキストが入っているときにsearchWordに格納
        if let searchWord = searchBar.text {
            // デバッグエリアに出力
            print(searchWord)
            // 入力されていたら、お菓子を検索
            searchOkashi(keyword: searchWord)
        }
    }
    
    // JSONのItem内のデータ構造
    struct ItemJson: Codable {
        // お菓子の名称
        let name: String?
        // メーカー
        let maker: String?
        // 掲載URL
        let url: URL?
        // 画像URL
        let image: URL?
    }
    
    // JSONのデータ構造
    struct ResultJson: Codable {
        // 複数要素
        let item:[ItemJson]?
    }
    
    // searchOkashiメソッド
    // 第一引数：keyword 検索したいワード
    func searchOkashi(keyword: String) {
        // お菓子の検索キーワードをURLエンコードする
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        // リクエストURLの組み立て
        guard let req_url = URL(string: "http://www.sysbird.jp/webapi/?apikey=guest&format=json&keyword=\(keyword_encode)&max=10&order=r") else {
            return
        }
        // 出力
        print(req_url)
        
        // リクエストに必要な情報を生成
        let _req = URLRequest(url: req_url)
        // データ転送を管理するためのセッションを生成
        let _session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        // リクエストをタスクとして登録
        let task = _session.dataTask(with: _req, completionHandler: { (data, response, error) in
            // セッションを終了
            _session.finishTasksAndInvalidate()
            do {
                // do try catch エラーハンドリング
                let _decoder = JSONDecoder()
                // 受け取ったJSONデータをパース（解析）して格納
                let json = try _decoder.decode(ResultJson.self, from: data!)
                // 出力
                print(json)
            } catch {
                // エラー処理
                print("エラーが出ました")
            }
        })
        task.resume()
    }
}
