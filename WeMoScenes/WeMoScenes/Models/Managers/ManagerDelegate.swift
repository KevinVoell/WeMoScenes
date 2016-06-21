//
//  ManagerDelegate.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/11/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import Foundation

internal protocol ManagerDelegate : class {
  /**
   * itemAdded: Invoked when a new item is added to the item list.
   */
  func itemAdded()
}