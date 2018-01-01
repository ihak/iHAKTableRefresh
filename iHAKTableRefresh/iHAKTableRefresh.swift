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

@objc enum RefreshState: Int {
    case Normal, Pulled, Loading
}

class iHAKTableRefresh: NSObject, UITableViewDelegate {
    var topViewHeight = CGFloat(60.0)
    var bottomViewHeight = CGFloat(40.0)
    var defaultContentOffset = CGFloat(0.0)
    
    var topViewEnabled = true
    var bottomViewEnabled = true
    
    var topRefreshState = RefreshState.Normal {
        didSet {
            updateTopView()
            
            if oldValue != topRefreshState {
                self.didChangeTopRefreshState()
            }
        }
    }
    
    var bottomRefreshState = RefreshState.Normal {
        didSet {
            updateBottomView()
            
            if oldValue != bottomRefreshState {
                self.didChangeBottomRefreshState()
            }
        }
    }
    
    var refreshType = RefreshType.TopAndBottom
    
    weak var tableView: UITableView!
    weak var delegate: iHAKTableRefreshDelegate!
    weak var dataSource: iHAKTableRefreshDataSource!
    
    var topView: UIView?
    var bottomView: UIView?
    
    private var topLabel: UILabel?
    private var bottomLabel: UILabel?
    
    private var topActivityIndicator: UIActivityIndicatorView?
    private var bottomActivityIndicator: UIActivityIndicatorView?
    
    private var bottomViewConstriant: NSLayoutConstraint?
    
    private var lastUpdated: NSDate?
    
    // MARK: - Initializers
    
    /// Default initializer. Initializes the instance with given tableview and delegate.
    /// By default sets refresh type to .TopAndBottom i.e boht top and bottom refresh are enabled.
    ///
    /// - parameter tableView: UITableView instance you want to add refresh control to.
    /// - parameter delegate:  An instance that implements iHAKTableRefreshDelegate.
    
    init(tableView: UITableView, delegate: iHAKTableRefreshDelegate) {
        super.init()
        
        self.tableView = tableView
        self.tableView.delegate = self
        self.delegate = delegate
    }
    
    /// Convenience initializer that takes and object that implements
    /// iHAKTableRefreshDataSource as well along with iHAKTableRefreshDelegate.
    ///
    /// Use this method if you want to use your custom top and bottom views.
    ///
    /// - parameter tableView:  UITableView instance you want to add refresh control to.
    /// - parameter delegate: An instance that implements iHAKTableRefreshDelegate.
    /// - parameter dataSource: An instance that implements iHAKTableRefreshDataSource.
    
    convenience init(tableView: UITableView, delegate: iHAKTableRefreshDelegate, dataSource: iHAKTableRefreshDataSource?) {
        self.init(tableView: tableView, delegate: delegate)
        self.dataSource = dataSource
    }
    
    /// Convenience initializer that allows you to choose the refresh type (Top|Bottom|TopAndBottom),
    /// define delegate and datasource.
    
    /// Use this method if you want to choose from the available RereshType(s). Implement iHAKTableRefreshDataSource
    /// if you want to provide your custom top or bottom views.
    ///
    /// - parameter tableView: UITableView instance you want to add refresh control to.
    /// - parameter refreshType: Choose from top, bottom or top and bottom refresh types.
    /// - parameter delegate: An instance that implements iHAKTableRefreshDelgate.
    /// - parameter dataSource: An instance that implements iHAKTableRefreshDataSource.
    
    convenience init(tableView: UITableView, refreshType: RefreshType, delegate: iHAKTableRefreshDelegate, dataSource: iHAKTableRefreshDataSource?) {
        self.init(tableView: tableView, delegate: delegate, dataSource: dataSource)
        self.refreshType = refreshType
        
        topViewEnabled = false
        bottomViewEnabled = false
        
        switch refreshType {
        case .Top:
            topViewEnabled = true
            addTopView()
        case .Bottom:
            bottomViewEnabled = true
            addBottomView()
        case .TopAndBottom:
            topViewEnabled = true
            bottomViewEnabled = true
            addTopView()
            addBottomView()
        }
        
        if refreshType == .Bottom || refreshType == .TopAndBottom {
            self.tableView.addObserver(self, forKeyPath: #keyPath(UITableView.contentSize), options: .new, context: nil)
        }
    }
    
    deinit {
        self.tableView.removeObserver(self, forKeyPath: #keyPath(UITableView.contentSize))
    }
    
    // MARK: - Top and bottom views
    
    /// Adds bottom view to the tableview.
    
    private func addTopView() {
        let topView = getTopView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.addSubview(topView)
        self.tableView.addConstraint(NSLayoutConstraint(item: topView, attribute: .width, relatedBy: .equal, toItem: self.tableView, attribute: .width, multiplier: 1.0, constant: 0.0))
        self.tableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topView]|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["topView":topView]))
        self.tableView.addConstraint(NSLayoutConstraint(item: topView, attribute: .bottom, relatedBy: .equal, toItem: self.tableView, attribute: .top, multiplier: 1.0, constant: 0.0))
    }
    
    /// Gets a top view either by using datasource method or by creating a default one.
    /// - returns: The created UIView
    
    private func getTopView() -> UIView {
        if let topViewHeight = self.dataSource?.iHAKTableRefreshHeightForTopView?(refreshView: self) {
            self.topViewHeight = CGFloat(topViewHeight)
        }
        
        var view: UIView
        
        if let topView = self.dataSource?.iHAKTableRefreshTopView?(refreshView: self) {
            view = topView
            self.topView = view
        }
        else {
            view = createTopView()
        }
        
        return view
    }
    
    /// Creates and return the default top view.
    /// - returns: The created UIView
    
    private func createTopView() -> UIView {
        let topView = UIView()
        topView.backgroundColor = UIColor.clear
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.addConstraint(NSLayoutConstraint(item: topView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: topViewHeight))
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Pull to Refresh", comment: "")
        label.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightLight)
        topView.addSubview(label)
        topView.addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: topView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        topView.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: topView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        topView.addSubview(activityIndicator)
        topView.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: topView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        topView.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: topView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        self.topLabel = label
        self.topView = topView
        self.topActivityIndicator = activityIndicator
        return self.topView!
    }
    
    /// Adds bottom view to the tableview.
    
    private func addBottomView() {
        let bottomView = getBottomView()
        self.tableView.addSubview(bottomView)
        self.tableView.addConstraint(NSLayoutConstraint(item: bottomView, attribute: .width, relatedBy: .equal, toItem: self.tableView, attribute: .width, multiplier: 1.0, constant: 0.0))
        self.tableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomView]|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["bottomView":bottomView]))
        self.bottomViewConstriant = NSLayoutConstraint(item: bottomView, attribute: .top, relatedBy: .equal, toItem: self.tableView, attribute: .bottom, multiplier: 1.0, constant: tableView.contentSize.height)
        self.tableView.addConstraint(self.bottomViewConstriant!)
    }
    
    /// Gets a bottom view either by using datasource method or by creating a default one.
    /// - returns: The created UIView
    
    private func getBottomView() -> UIView {
        if let bottomViewHeight = self.dataSource?.iHAKTableRefreshHeightForBottomView?(refreshView: self) {
            self.bottomViewHeight = CGFloat(bottomViewHeight)
        }
        
        var view: UIView
        
        if let bottomView = self.dataSource?.iHAKTableRefreshBottomView?(refreshView: self) {
            view = bottomView
            self.bottomView = view
        }
        else {
            view = createBottomView()
        }
        
        return view
    }
    
    /// Creates and return the default bottom view.
    /// - returns: The created UIView
    
    private func createBottomView() -> UIView {
        let bottomView = UIView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addConstraint(NSLayoutConstraint(item: bottomView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: bottomViewHeight))
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Load More Data", comment: "")
        label.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightLight)
        bottomView.addSubview(label)
        bottomView.addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: bottomView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        bottomView.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: bottomView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        bottomView.addSubview(activityIndicator)
        bottomView.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .right, relatedBy: .equal, toItem: label, attribute: .left, multiplier: 1.0, constant: -10.0))
        bottomView.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: label, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        self.bottomLabel = label
        self.bottomView = bottomView
        self.bottomActivityIndicator = activityIndicator
        return self.bottomView!
    }
    
    //MARK: - Update methods
    private func updateTopRefreshState(state: RefreshState) {
        topRefreshState = state
        switch state {
        case .Loading:
            //            print("Top refresh state: Loading")
            animateScrollView(insets: UIEdgeInsetsMake(topViewHeight-defaultContentOffset, 0.0, 0.0, 0.0), duration: 0.2)
            break
        case .Normal:
            //            print("Top refresh state: Normal")
            break
        case .Pulled:
            //            print("Top refresh state: Pulled")
            break
        }
    }
    
    private func updateBottomRefreshState(state: RefreshState) {
        bottomRefreshState = state
        switch state {
        case .Loading:
            //            print("Bottom refresh state: Loading")
            animateScrollView(insets: UIEdgeInsetsMake(0.0, 0.0, bottomViewHeight, 0.0), duration: 0.2)
            break
        case .Normal:
            //            print("Bottom refresh state: Normal")
            break
        case .Pulled:
            //            print("Bottom refresh state: Pulled")
            break
        }
    }
    
    private func updateTopView() {
        if topRefreshState == .Pulled {
            self.topLabel?.text = NSLocalizedString("Release to Refresh", comment: "")
        }
        else if topRefreshState == .Normal {
            if let updatedAt = formattedLastUpdate() {
                self.topLabel?.text = String.init(format: NSLocalizedString("Last updated on %@", comment: ""), updatedAt)
            }
            else {
                self.topLabel?.text = NSLocalizedString("Pull to Refresh", comment: "")
            }
            
            topActivityIndicator?.stopAnimating()
            self.topLabel?.isHidden = false
            
            if !self.tableView.isDragging {
                animateScrollView(insets: UIEdgeInsetsMake(-defaultContentOffset, 0.0, 0.0, 0.0), duration: 0.2)
            }
        }
        else if topRefreshState == .Loading {
            self.topLabel?.isHidden = true
            topActivityIndicator?.startAnimating()
        }
    }
    
    private func updateBottomView() {
        if let bottomLabel = self.bottomLabel {
            if bottomRefreshState == .Normal {
                bottomLabel.text = NSLocalizedString("Load More Data", comment: "")
                bottomActivityIndicator?.stopAnimating()
            }
            else if bottomRefreshState == .Loading {
                bottomLabel.text = NSLocalizedString("Loading", comment: "")
                bottomActivityIndicator?.startAnimating()
            }
        }
    }
    
    //MARK: - Bottom view
    
    /// This method permanantly disables the bottom view.
    /// it sets refreshtype to top only, sets bottom refrsh state to normal, removes bottom view and disables it.
    
    func disableBottomRefresh() {
        self.refreshType = .Top
        self.bottomView?.removeFromSuperview()
        self.bottomViewEnabled = false
        self.bottomRefreshState = .Normal
    }
    
    /// Hides bottom refresh view. Call this method when you don't have more data to load.
    /// Or you can call it at the start when the tableview is empty.
    
    func hideBottomRefresh() {
        self.bottomView?.isHidden = true
    }
    
    /// Shows the bottom refresh view. Call this method when you have data to load.
    
    func showBottomRefresh() {
        self.bottomView?.isHidden = false
    }
    
    /// Call this method to manually trigger top refresh. This method
    /// don't take into account topViewEnabled property. Nor it trigger the delegate
    /// shouldPerformTopRefresh.
    
    func triggerTopRefresh() {
        // Scroll the view down to show top view
        self.tableView.setContentOffset(CGPoint.init(x: 0.0, y: topViewHeight * -1.0), animated: true)
        
        // Trigger the delegate and change state to loading
        self.delegate.iHAKTableRefreshWillPerformTopRefresh(refreshView: self)
        updateTopRefreshState(state: .Loading)
    }
    
    private func didChangeTopRefreshState() {
        self.delegate?.iHAKTableRefreshDidChangeTopRefreshState?(refreshView: self, state: self.topRefreshState)
    }
    
    private func didChangeBottomRefreshState() {
        self.delegate?.iHAKTableRefreshDidChangeBottomRefreshState?(refreshView: self, state: self.bottomRefreshState)
    }
    
    
    /// Call this method to finish refreshing the table view.
    ///
    /// - parameter success: A bool that tells if the refresh action was successful or not.
    
    func finishRefresh(success: Bool) {
        
        if success && self.topRefreshState == .Loading {
            lastUpdated = NSDate()
        }
        
        if self.topRefreshState == .Loading {
            self.delegate?.iHAKTableRefreshDidCompleteTopRefresh?(refreshView: self)
        }
        
        if self.bottomRefreshState == .Loading {
            self.delegate?.iHAKTableRefreshDidCompleteBottomRefresh?(refreshView: self)
        }
        
        self.topRefreshState = .Normal
        self.bottomRefreshState = .Normal
    }
    
    private func shouldPerformTopRefresh() -> Bool {
        if let returnValue = delegate.iHAKTableRefreshShouldPerformTopRefresh?(refreshView: self) {
            return returnValue
        }
        return true
    }
    
    private func shouldPerformBottomRefresh() -> Bool {
        if let returnValue = delegate.iHAKTableRefreshShouldPerformBottomRefresh?(refreshView: self) {
            return returnValue
        }
        return true
    }
    
    private func animateScrollView(insets: UIEdgeInsets, duration:TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.tableView.contentInset = insets
        }
    }
    
    private func formattedLastUpdate() -> String? {
        if let date = lastUpdated {
            let df = DateFormatter()
            df.dateFormat = "dd MMM hh:mm a"
            return df.string(from: date as Date)
        }
        return nil
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.iHAKTableRefreshTable?(tableview: tableView, didSelectRow: indexPath)
    }
    
    //MARK: - UIScrollViewDelegate
    @objc func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging else {
            return
        }
        
        //        print("frame height: \(scrollView.frame.height)), content height: \(scrollView.contentSize.height), content offset: \(scrollView.contentOffset.y)")
        
        if topRefreshState != .Loading && topViewEnabled {
            if (scrollView.contentOffset.y-defaultContentOffset) <= -topViewHeight {
                updateTopRefreshState(state: .Pulled)
            }
            else {
                updateTopRefreshState(state: .Normal)
            }
        }
        
        if bottomRefreshState != .Loading && bottomViewEnabled {
            // If content is less than the scrollview frame
            if scrollView.contentSize.height <= scrollView.frame.height {
                //                print("\((scrollView.contentOffset.y-defaultContentOffset)) >= \(bottomViewHeight))")
                if (scrollView.contentOffset.y-defaultContentOffset) >= bottomViewHeight {
                    updateBottomRefreshState(state: .Pulled)
                }
                else {
                    updateBottomRefreshState(state: .Normal)
                }
            }
            else if scrollView.contentSize.height > scrollView.frame.height {
                if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.height) + bottomViewHeight {
                    updateBottomRefreshState(state: .Pulled)
                }
                else {
                    updateBottomRefreshState(state: .Normal)
                }
            }
        }
    }
    
    @objc func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if topRefreshState == .Pulled && topViewEnabled {
            if shouldPerformTopRefresh() {
                self.delegate.iHAKTableRefreshWillPerformTopRefresh(refreshView: self)
                updateTopRefreshState(state: .Loading)
            }
        }
        
        if bottomRefreshState == .Pulled && bottomViewEnabled {
            if shouldPerformBottomRefresh() {
                self.delegate.iHAKTableRefreshWillPerformBottomRefresh(refreshView: self)
                updateBottomRefreshState(state: .Loading)
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
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
    
    /**
     Implement this method if you are interested in the state of the top view.
     iHAKTableRefresh has three states (Normal, Pulled and Loading) denoted by RefreshState enum.
     */
    @objc optional func iHAKTableRefreshDidChangeTopRefreshState(refreshView: iHAKTableRefresh, state: RefreshState)
    
    /**
     Implement this method if you are interested in the state of the bottom view.
     iHAKTableRefresh has three states (Normal, Pulled and Loading) denoted by RefreshState enum.
     */
    @objc optional func iHAKTableRefreshDidChangeBottomRefreshState(refreshView: iHAKTableRefresh, state: RefreshState)
    
    /**
    Implement this method to do extra work at the end of top refresh.
    */
    @objc optional func iHAKTableRefreshDidCompleteTopRefresh(refreshView: iHAKTableRefresh)

    /**
     Implement this method to do extra work at the end of bottom refresh.
     */
    @objc optional func iHAKTableRefreshDidCompleteBottomRefresh(refreshView: iHAKTableRefresh)
    
    /**
     Implement this method if you want to get UITableViewDelegate's didSelectRow method
     */
    @objc optional func iHAKTableRefreshTable(tableview: UITableView, didSelectRow atIndex: IndexPath)
}

@objc protocol iHAKTableRefreshDataSource {
    /**
     Implement this method to provide a custom top view height.
     */
    @objc optional func iHAKTableRefreshHeightForTopView(refreshView: iHAKTableRefresh) -> Double
    
    /**
     Implement this method to provide a custom top view.
     */
    @objc optional func iHAKTableRefreshTopView(refreshView: iHAKTableRefresh) -> UIView
    
    /**
     Implement this method to provide a custom bottom view height.
     */
    @objc optional func iHAKTableRefreshHeightForBottomView(refreshView: iHAKTableRefresh) -> Double
    
    /**
     Implement this mehtod to provide a custom bottom view.
     */
    @objc optional func iHAKTableRefreshBottomView(refreshView: iHAKTableRefresh) -> UIView
}
