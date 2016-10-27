//
//  ViewController.swift
//  iHAKTableRefresh
//
//  Created by Hassan Ahmed on 10/18/16.
//  Copyright © 2016 Hassan Ahmed. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, iHAKTableRefreshDelegate, iHAKTableRefreshDataSource {
    let CellIdentifier = "CellIdentifier"
    var tableRefresh: iHAKTableRefresh!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: CellIdentifier)
        
        tableRefresh = iHAKTableRefresh(tableView: tableView, refreshType: .TopAndBottom, delegate: self, dataSource: self)
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
            refreshView.finishRefresh(true)
        }
    }
    
    func iHAKTableRefreshShouldPerformBottomRefresh(refreshView: iHAKTableRefresh) -> Bool {
        return true
    }
    
    func iHAKTableRefreshWillPerformBottomRefresh(refreshView: iHAKTableRefresh) {
        refreshView.finishRefresh(false)
    }
    
    //MARK: - iHAKTableRefreshDataSource
    func iHAKTableRefreshHeightForTopView(refreshView: iHAKTableRefresh) -> Double {
        return 100.0
    }
    
    func iHAKTableRefreshTopView(refreshView: iHAKTableRefresh) -> UIView {
        let topView = UIView()
        topView.backgroundColor = UIColor.whiteColor()
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.addConstraint(NSLayoutConstraint(item: topView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: refreshView.topViewHeight))
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Pull to Refresh"
        topView.addSubview(label)
        topView.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: topView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        topView.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: topView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        topView.addSubview(activityIndicator)
        topView.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: topView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        topView.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: topView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        
        return topView
    }
}
