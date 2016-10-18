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
    
    var topRefreshState = RefreshState.Normal
    var bottomRefreshState = RefreshState.Normal
    
    var refreshType = RefreshType.TopAndBottom
    
    weak var tableView: UITableView!
    weak var delegate: iHAKTableRefreshDelegate!
    
    var topView: UIView?
    var bottomView: UIView?
    
    
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
        }
    }
    
    func updateTopRefreshState(state: RefreshState) {
        topRefreshState = state
        switch state {
        case .Loading:
            print("Top refresh state: Loading")
            animateScrollView(UIEdgeInsetsMake(topViewHeight, 0.0, 0.0, 0.0), duration: 0.2)
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

    func shouldPerformTopRefresh() -> Bool {
        if let returnValue = delegate.shouldPerformTopRefresh?() {
            return returnValue
        }
        return true
    }
    
    func shouldPerformBottomRefresh() -> Bool {
        if let returnValue = delegate.shouldPerformBottomRefresh?() {
            return returnValue
        }
        return true
    }
    
    func animateScrollView(insets: UIEdgeInsets, duration:NSTimeInterval) {
        UIView.animateWithDuration(duration) { 
            self.tableView.contentInset = insets
        }
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
            if (scrollView.contentOffset.y+defaultContentOffset) <= -topViewHeight {
                updateTopRefreshState(.Pulled)
            }
            else {
                updateTopRefreshState(.Normal)
            }
        }
        
        if bottomRefreshState != .Loading && bottomViewEnabled {
            // If content is less than the scrollview frame
            if scrollView.contentSize.height <= scrollView.frame.height {
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
                updateTopRefreshState(.Loading)
            }
        }
        
        if bottomRefreshState == .Pulled && bottomViewEnabled {
            if shouldPerformBottomRefresh() {
                updateBottomRefreshState(.Loading)
            }
        }
    }
}

@objc protocol iHAKTableRefreshDelegate {
    /**
     Implement this method if you want to control when to refresh your view.
     Return false if you don't want top refresh. This method is not get called if 
     the property topViewEnabled is false.
     */
    @objc optional func shouldPerformTopRefresh() -> Bool
    
    /**
     Implement this method if you want to control when to refresh your view.
     Return false if you don't want bottom refresh. This method is not get called if
     the property bottomViewEnabled is false.
     */
    @objc optional func shouldPerformBottomRefresh() -> Bool
}