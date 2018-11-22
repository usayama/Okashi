//
//  ViewController.swift
//  Okashi
//
//  Created by Yusuke Nakane on 2018/11/20.
//  Copyright © 2018 usayama. All rights reserved.
//

import UIKit
import SafariServices


class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SFSafariViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // サーチバーのデリゲート通知先を設定
        searchText.delegate = self
        // 入力のヒントになるプレースホルダーを設定
        searchText.placeholder = "お菓子の名前を入力してください"
        // テーブルビューのデータソースを設定
        tableView.dataSource = self
        // テーブルビューのデリゲートを設定
        tableView.delegate = self
    }

    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // お菓子のリスト（タプル配列）
    var okashiList: [(name:String, maker:String, link:URL, image:URL)] = []
    
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
                // お菓子の情報が取得できているか確認
                if let items = json.item {
                    // お菓子のリストを初期化
                    self.okashiList.removeAll()
                    // 取得しているお菓子の数だけ処理
                    for item in items {
                        // お菓子の名称、メーカー名、掲載URL、画像URLをアンラップ
                        if let name = item.name, let maker = item.maker, let link = item.url, let image = item.image {
                            // 1つのお菓子をタプルでまとめて管理
                            let okashi = (name, maker, link, image)
                            // お菓子の配列へ追加
                            self.okashiList.append(okashi)
                        }
                    }
                    // テーブルビューを更新する
                    self.tableView.reloadData()
                    if let okashidbg = self.okashiList.first {
                        print("--------------------")
                        print("okashiList[0] = \(okashidbg)")
                    }
                }
            } catch {
                // エラー処理
                print("エラーが出ました")
            }
        })
        task.resume()
    }
    
    // Cellの総数を返すdetasourceメソッド、必ず記述する必要があります
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // お菓子リストの総数
        return okashiList.count
    }
    
    // Cellに値を設定するdatasourceメソッド。必ず記述する必要があります
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 今回表示を行う、Cellオブジェクト（1行）を取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "okashiCell", for: indexPath)
        // お菓子のタイトル設定
        cell.textLabel?.text = okashiList[indexPath.row].name
        // お菓子画像を取得
        if let imageData = try? Data(contentsOf: okashiList[indexPath.row].image) {
            // 正常に取得できた場合は、UIImageで画像オブジェクトを生成して、Cellにお菓子画像を設定
            cell.imageView?.image = UIImage(data: imageData)
        }
        // 設定済みのCellオブジェクトを画面に反映
        return cell
    }
    
    // Cellが選択されたときに呼び出されるデリゲートメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // ハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
        // SFSafariViewを開く
        let safariViewController = SFSafariViewController(url: okashiList[indexPath.row].link)
        // デリゲートの通知先を自分自身
        safariViewController.delegate = self
        // サファリビューが開かれる
        present(safariViewController, animated: true, completion: nil)
    }
    
    // サファリビューが閉じられたときに呼ばれるデリゲートメソッド
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // サファリビューを閉じる
        dismiss(animated: true, completion: nil)
    }
}
