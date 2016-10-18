//
//  ViewController.swift
//  iHAKTableRefresh
//
//  Created by Hassan Ahmed on 10/18/16.
//  Copyright © 2016 Hassan Ahmed. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, iHAKTableRefreshDelegate {
    let CellIdentifier = "CellIdentifier"
    var tableRefresh: iHAKTableRefresh!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: CellIdentifier)
        
        tableRefresh = iHAKTableRefresh(tableView: tableView, refreshType: .TopAndBottom, delegate: self)
        tableRefresh.defaultContentOffset = -64.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)
        cell?.textLabel?.text = "Cell \(indexPath.row)"
        return cell!
    }
    
    //MARK: - iHAKTableRefreshDelegate
    func iHAKTableRefreshShouldPerformTopRefresh(refreshView: iHAKTableRefresh) -> Bool {
        return true
    }
    
    func iHAKTableRefreshWillPerformTopRefresh(refreshView: iHAKTableRefresh) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(3.0) * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            refreshView.finishRefresh()
        }
    }
    
    func iHAKTableRefreshShouldPerformBottomRefresh(refreshView: iHAKTableRefresh) -> Bool {
        return false
    }
    
    func iHAKTableRefreshWillPerformBottomRefresh(refreshView: iHAKTableRefresh) {
        refreshView.finishRefresh()
    }
}

