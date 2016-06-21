//
//  SceneDevice.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/11/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import Foundation

internal class SceneDeviceModel : ModelBase {
  
  internal enum StateValues : Int {
    case On
    case Off
    case Ignore
  }
  
  static var tableName: String? {
    get { return "SceneDevice" }
  }
  
  static var sortKey: String? {
    get { return "Name" }
  }
  
  var key: String? {
    return ""
  }
  
  /**
   * deviceId: The id of the related device object.
   */
  internal var deviceId: String?
  
  /**
   * state: The state of the device in this scene.
   */
  internal var state: StateValues?
  
  internal required init(fromJSON: String) {
    
  }
  
  internal init() {
    
  }
  
  internal func toJson() -> String {
    return "";
  }
}
