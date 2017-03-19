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
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: CellIdentifier)
        
        tableRefresh = iHAKTableRefresh(tableView: tableView, refreshType: .TopAndBottom, delegate: self, dataSource: nil)
        tableRefresh.defaultContentOffset = -64.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
        cell?.textLabel?.text = "Cell \(indexPath.row)"
        return cell!
    }
    
    //MARK: - iHAKTableRefreshDelegate
    func iHAKTableRefreshShouldPerformTopRefresh(refreshView: iHAKTableRefresh) -> Bool {
        return true
    }
    
    func iHAKTableRefreshWillPerformTopRefresh(refreshView: iHAKTableRefresh) {
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            refreshView.finishRefresh(success: true)
        })

    }
    
    func iHAKTableRefreshShouldPerformBottomRefresh(refreshView: iHAKTableRefresh) -> Bool {
        refreshView.disableBottomRefresh()
        return false
    }
    
    func iHAKTableRefreshWillPerformBottomRefresh(refreshView: iHAKTableRefresh) {
        refreshView.finishRefresh(success: false)
    }
    
    func iHAKTableRefreshDidChangeTopRefreshState(refreshView: iHAKTableRefresh, state: RefreshState) {
        print("State changed")
    }
    
    //MARK: - iHAKTableRefreshDataSource
    func iHAKTableRefreshHeightForTopView(refreshView: iHAKTableRefresh) -> Double {
        return 100.0
    }
    
    func iHAKTableRefreshTopView(refreshView: iHAKTableRefresh) -> UIView {
        let topView = UIView()
        topView.backgroundColor = UIColor.white
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.addConstraint(NSLayoutConstraint(item: topView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: refreshView.topViewHeight))
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Pull to Refresh"
        topView.addSubview(label)
        topView.addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: topView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        topView.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: topView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        topView.addSubview(activityIndicator)
        topView.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: topView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        topView.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: topView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        return topView
    }
}
