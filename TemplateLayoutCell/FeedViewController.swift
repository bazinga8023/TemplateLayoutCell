//
//  FeedViewController.swift
//  TemplateLayoutCell
//
//  Created by 张俊安 on 2018/3/13.
//  Copyright © 2018年 John.Zhang. All rights reserved.
//

import UIKit


class FeedViewController: UITableViewController {

    var feedEntitySections = [FeedEntity]()

    override func viewDidLoad() {
        super.viewDidLoad()

        buildTestData {
            self.tableView.reloadData()
        }


        

    }

    func buildTestData(then: (() -> ())?) {
        DispatchQueue.global().async {
            if let dataFilePath = Bundle.main.path(forResource: "data", ofType: "json"),
                let data = NSData.init(contentsOfFile: dataFilePath),
                let tempRootDict = try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments),
                let rootDict = tempRootDict as? [String: Any],
                let feedDicts = rootDict["feed"] as? [Any] {

                var entities = [FeedEntity]()
                feedDicts.forEach({ (dict) in
                    entities.append(FeedEntity.init(with: dict as! [String : String]))
                })

                self.feedEntitySections = entities

                DispatchQueue.main.async {
                    (then != nil) == true ? then!() : ()
                }
            }
        }
    }


}

// MARK: - Data source
extension FeedViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedEntitySections.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as? FeedCell else {
            return UITableViewCell()
        }
        cell.enForceFrameLayout = false
        cell.entity = feedEntitySections[indexPath.row]
        return cell
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return ["A", "B", "C"]
    }
}

// MARK: - Delegate
extension FeedViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return CGFloat(tableView.heightForCell(with: "FeedCell", cacheBy: feedEntitySections[indexPath.row].identifier, configuration: { [weak self] (cell) in
            if let `self` = self, let cell = cell as? FeedCell {
                cell.enForceFrameLayout = false
                cell.entity = self.feedEntitySections[indexPath.row]
            }
        }))
    }
}





