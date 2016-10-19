//
//  iHAKTableRefresh.swift
//  iHAKTableRefresh
//
//  Created by Hassan Ahmed on 10/18/16.
//  Copyright © 2016 Hassan Ahmed. All rights reserved.
//

import Foundation
import UIKit

enum RefreshType {
    case Top, Bottom, TopAndBottom
}

class iHAKTableRefresh: NSObject, UITableViewDelegate {
    var topViewHeight = CGFloat(60.0)
    var bottomViewHeight = CGFloat(40.0)
    var defaultContentOffset = CGFloat(0.0)
    
    var topViewEnabled = true
    var bottomViewEnabled = true
    
    enum RefreshState {
        case Normal, Pulled, Loading
    }
    
    var topRefreshState = RefreshState.Normal {
        didSet {
            updateTopView()
        }
    }
    
    var bottomRefreshState = RefreshState.Normal {
        didSet {
            updateBottomView()
        }
    }
    
    var refreshType = RefreshType.TopAndBottom
    
    weak var tableView: UITableView!
    weak var delegate: iHAKTableRefreshDelegate!
    
    var topView: UIView?
    var bottomView: UIView?
    
    private var topLabel: UILabel?
    private var bottomLabel: UILabel?
    
    private var topActivityIndicator: UIActivityIndicatorView?
    private var bottomActivityIndicator: UIActivityIndicatorView?
    
    private var bottomViewConstriant: NSLayoutConstraint?
    
    private var lastUpdated: NSDate?
    
    init(tableView: UITableView, delegate: iHAKTableRefreshDelegate) {
        super.init()
        
        self.tableView = tableView
        self.tableView.delegate = self
        self.delegate = delegate
    }
    
    convenience init(tableView: UITableView, refreshType: RefreshType, delegate: iHAKTableRefreshDelegate) {
        self.init(tableView: tableView, delegate: delegate)
        self.refreshType = refreshType
        
        topViewEnabled = false
        bottomViewEnabled = false
        
        switch refreshType {
        case .Top:
            topViewEnabled = true
        case .Bottom:
            bottomViewEnabled = true
        case .TopAndBottom:
            topViewEnabled = true
            bottomViewEnabled = true
            addTopView()
            addBottomView()
        }
        
        if refreshType == .Bottom || refreshType == .TopAndBottom {
            self.tableView .addObserver(self, forKeyPath: "contentSize", options: .New, context: nil)
        }
    }
    
    func addTopView() {
        let topView = createTopView()
        self.tableView.addSubview(topView)
        self.tableView.addConstraint(NSLayoutConstraint(item: topView, attribute: .Width, relatedBy: .Equal, toItem: self.tableView, attribute: .Width, multiplier: 1.0, constant: 0.0))
        self.tableView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[topView]|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["topView":topView]))
        self.tableView.addConstraint(NSLayoutConstraint(item: topView, attribute: .Bottom, relatedBy: .Equal, toItem: self.tableView, attribute: .Top, multiplier: 1.0, constant: 0.0))
    }
    
    func createTopView() -> UIView {
        let topView = UIView()
        topView.backgroundColor = UIColor.whiteColor()
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.addConstraint(NSLayoutConstraint(item: topView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: topViewHeight))
        
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
        
        self.topLabel = label
        self.topView = topView
        self.topActivityIndicator = activityIndicator
        return self.topView!
    }
    
    func addBottomView() {
        let bottomView = createBottomView()
        self.tableView.addSubview(bottomView)
        self.tableView.addConstraint(NSLayoutConstraint(item: bottomView, attribute: .Width, relatedBy: .Equal, toItem: self.tableView, attribute: .Width, multiplier: 1.0, constant: 0.0))
        self.tableView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bottomView]|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["bottomView":bottomView]))
        self.bottomViewConstriant = NSLayoutConstraint(item: bottomView, attribute: .Top, relatedBy: .Equal, toItem: self.tableView, attribute: .Bottom, multiplier: 1.0, constant: tableView.contentSize.height)
        self.tableView.addConstraint(self.bottomViewConstriant!)
    }
    
    func createBottomView() -> UIView {
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor.redColor()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addConstraint(NSLayoutConstraint(item: bottomView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: topViewHeight))
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Load More Data"
        bottomView.addSubview(label)
        bottomView.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: bottomView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        bottomView.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: bottomView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        bottomView.addSubview(activityIndicator)
        bottomView.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .Right, relatedBy: .Equal, toItem: label, attribute: .Left, multiplier: 1.0, constant: 0.0))
        bottomView.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: label, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        
        self.bottomLabel = label
        self.bottomView = bottomView
        self.bottomActivityIndicator = activityIndicator
        return self.bottomView!
    }
    
    func updateTopRefreshState(state: RefreshState) {
        topRefreshState = state
        switch state {
        case .Loading:
            print("Top refresh state: Loading")
            animateScrollView(UIEdgeInsetsMake(topViewHeight-defaultContentOffset, 0.0, 0.0, 0.0), duration: 0.2)
            break
        case .Normal:
            print("Top refresh state: Normal")
            break
        case .Pulled:
            print("Top refresh state: Pulled")
            break
        }
    }

    func updateBottomRefreshState(state: RefreshState) {
        bottomRefreshState = state
        switch state {
        case .Loading:
            print("Bottom refresh state: Loading")
            animateScrollView(UIEdgeInsetsMake(0.0, 0.0, bottomViewHeight, 0.0), duration: 0.2)
            break
        case .Normal:
            print("Bottom refresh state: Normal")
            break
        case .Pulled:
            print("Bottom refresh state: Pulled")
            break
        }        
    }

    func updateTopView() {
        if let topLabel = self.topLabel {
            if topRefreshState == .Pulled {
                self.topLabel?.text = "Release to Refresh"
            }
            else if topRefreshState == .Normal {
                if let updatedAt = formattedLastUpdate() {
                    topLabel.text = "Last updated on \(updatedAt)"
                }
                else {
                    self.topLabel?.text = "Pull to Refresh"
                }
                
                topActivityIndicator?.stopAnimating()
                topLabel.hidden = false
                
                if !self.tableView.dragging {
                    animateScrollView(UIEdgeInsetsMake(-defaultContentOffset, 0.0, 0.0, 0.0), duration: 0.2)
                }
            }
            else if topRefreshState == .Loading {
                topLabel.hidden = true
                topActivityIndicator?.startAnimating()
            }
        }
    }
    
    func updateBottomView() {
        if let bottomLabel = self.bottomLabel {
            if bottomRefreshState == .Normal {
                bottomLabel.text = "Load More Data"
                bottomActivityIndicator?.stopAnimating()
            }
            else if bottomRefreshState == .Loading {
                bottomLabel.text = "Loading"
                bottomActivityIndicator?.startAnimating()
            }
        }
    }
    
    /**
     * Call this method to finish refreshing the table view.
     *
     * @param success A bool that tells if the refresh action was successful or not.
     */
    func finishRefresh(success: Bool) {
        
        if success && self.topRefreshState == .Loading {
            lastUpdated = NSDate()
        }
        
        self.topRefreshState = .Normal
        self.bottomRefreshState = .Normal
    }
    
    func shouldPerformTopRefresh() -> Bool {
        if let returnValue = delegate.iHAKTableRefreshShouldPerformTopRefresh?(self) {
            return returnValue
        }
        return true
    }
    
    func shouldPerformBottomRefresh() -> Bool {
        if let returnValue = delegate.iHAKTableRefreshShouldPerformBottomRefresh?(self) {
            return returnValue
        }
        return true
    }
    
    func animateScrollView(insets: UIEdgeInsets, duration:NSTimeInterval) {
        UIView.animateWithDuration(duration) { 
            self.tableView.contentInset = insets
        }
    }
    
    func formattedLastUpdate() -> String? {
        if let date = lastUpdated {
            let df = NSDateFormatter()
            df.dateFormat = "dd MMM hh:mm a"
            return df.stringFromDate(date)
        }
        return nil
    }
    
    /**
     Call this method when you have finished loading the data.
     */
    func finishedLoading(success: Bool) {
        // Change the refresh state to normal
        // adjust the content size of the tableview
        // If success is true, refresh the last updated date
    }
    
    //MARK: - UIScrollViewDelegate
    @objc func scrollViewDidScroll(scrollView: UIScrollView) {
        guard scrollView.dragging else {
            return
        }
        
        print("frame height: \(CGRectGetHeight(scrollView.frame))), content height: \(scrollView.contentSize.height), content offset: \(scrollView.contentOffset.y)")

        if topRefreshState != .Loading && topViewEnabled {
            if (scrollView.contentOffset.y-defaultContentOffset) <= -topViewHeight {
                updateTopRefreshState(.Pulled)
            }
            else {
                updateTopRefreshState(.Normal)
            }
        }
        
        if bottomRefreshState != .Loading && bottomViewEnabled {
            // If content is less than the scrollview frame
            if scrollView.contentSize.height <= scrollView.frame.height {
                print("\((scrollView.contentOffset.y-defaultContentOffset)) >= \(bottomViewHeight))")
                if (scrollView.contentOffset.y-defaultContentOffset) >= bottomViewHeight {
                    updateBottomRefreshState(.Pulled)
                }
                else {
                    updateBottomRefreshState(.Normal)
                }
            }
            else if scrollView.contentSize.height > scrollView.frame.height {
                if scrollView.contentOffset.y >= (scrollView.contentSize.height - CGRectGetHeight(scrollView.frame)) + bottomViewHeight {
                    updateBottomRefreshState(.Pulled)
                }
                else {
                    updateBottomRefreshState(.Normal)
                }
            }
        }
    }
    
    @objc func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if topRefreshState == .Pulled && topViewEnabled {
            if shouldPerformTopRefresh() {
                self.delegate.iHAKTableRefreshWillPerformTopRefresh(self)
                updateTopRefreshState(.Loading)
            }
        }
        
        if bottomRefreshState == .Pulled && bottomViewEnabled {
            if shouldPerformBottomRefresh() {
                self.delegate.iHAKTableRefreshWillPerformTopRefresh(self)
                updateBottomRefreshState(.Loading)
            }
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        self.bottomViewConstriant?.constant = self.tableView.contentSize.height
    }
}

@objc protocol iHAKTableRefreshDelegate {
    /**
     Implement this method if you want to control when to refresh your view.
     Return false if you don't want top refresh. This method is not get called if 
     the property topViewEnabled is false.
     */
    @objc optional func iHAKTableRefreshShouldPerformTopRefresh(refreshView: iHAKTableRefresh) -> Bool
    
    /**
     Implement this method if you want to control when to refresh your view.
     Return false if you don't want bottom refresh. This method is not get called if
     the property bottomViewEnabled is false.
     */
    @objc optional func iHAKTableRefreshShouldPerformBottomRefresh(refreshView: iHAKTableRefresh) -> Bool
    
    /**
     Implement this method to perform any data refresh on the tableview in case of top refresh.
    */
    func iHAKTableRefreshWillPerformTopRefresh(refreshView: iHAKTableRefresh)
    
    /**
     Implement this method to perform any data refresh on tableview in case of bottom refresh.
     */
    func iHAKTableRefreshWillPerformBottomRefresh(refreshView: iHAKTableRefresh)
}