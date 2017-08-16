# iHAKTableRefresh.swift
[![Swift](https://img.shields.io/badge/swift-3-orange.svg?style=flat)](https://developer.apple.com/swift/)

This is a simple swift class that works in tandem with UITableView to add top and bottom refresh functionalities.


## Preview

![alt tag](https://github.com/ihak/iHAKTableRefresh/blob/master/iHAKTableRefresh/1lopba.gif)


## Features

 - A pure-Swift interface
 - Easy to use
 - Highly customizable
 - Provides default functionalities out of the box for rapid development
 - A lightweight, uncomplicated
 - Developer-friendly
 - Actively developed and improved
 - Example implementation included
 
 ## Usage
 Drag and drop the iHAKTableRefresh.swift file from the cloned project into your own in Xcode's project pane.
 
 ```swift
 // declare the iHAKTableRefresh instance
 var tableRefresh: iHAKTableRefresh!
 
 // Initialize the instance in viewDidLoad method
     override func viewDidLoad() {
        super.viewDidLoad()
        
        tableRefresh = iHAKTableRefresh(tableView: tableView, refreshType: .TopAndBottom, delegate: self, dataSource: nil)
        tableRefresh.defaultContentOffset = -64.0
    }
 
 // Implement Delegate methods as required
 //MARK: - iHAKTableRefreshDelegate
    func iHAKTableRefreshShouldPerformTopRefresh(refreshView: iHAKTableRefresh) -> Bool {
      // Return true if you want the bottom refresh process to start
        return true
    }
    
    func iHAKTableRefreshWillPerformTopRefresh(refreshView: iHAKTableRefresh) {
      // Called when user finishes draging from the top and delegate return true 
      // in iHAKTableRefreshShouldPerformTopRefresh method.
      // Load any data here
    }
    
    func iHAKTableRefreshShouldPerformBottomRefresh(refreshView: iHAKTableRefresh) -> Bool {
    // Return true if you want the bottom refresh process to start
        return true
    }
    
    func iHAKTableRefreshWillPerformBottomRefresh(refreshView: iHAKTableRefresh) {
      // Called when user finishes draging from the bottom and delegate return true 
      // in iHAKTableRefreshShouldPerformBottomRefresh method.
      // Load any data here and append the table.
    
    }

