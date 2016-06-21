//
//  SceneModel.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/11/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import Foundation
import SwiftyJSON

internal class SceneModel : ModelBase {
  
  /**
   * tableName: The name of the table in the Firebase database.
   */
  internal static var tableName: String? {
    get { return "scenes" }
  }
  
  /**
   * sortKey: The key to sort by in the Firebase database.
   */
  internal static var sortKey: String? {
    get { return "name" }
  }
  
  var key: String? {
    return name
  }
  
  /**
   * name: The name of this scene
   */
  internal var name: String?
  
  /**
   * devices: The devices associated with this scene.
   */
  internal var devices: Array<SceneDeviceModel>?
  
  /**
   * init: Creates a new instance of this class from a JSON object.
   *
   * fromJSON: String The string containing the JSON object.
   */
  internal required init(fromJSON: String) {
    print(fromJSON)
    let json = JSON.parse(fromJSON)
    self.devices = Array<SceneDeviceModel>()
    
    if let name = json["name"].string {
      self.name = name
    }
    
    if let devices = json["devices"].array {
      for device in devices {
        
        let tempDevice = SceneDeviceModel()
        tempDevice.deviceId = device["deviceId"].stringValue
        switch device["state"].string! {
          case "On":
            tempDevice.state = SceneDeviceModel.StateValues.On
            break
          case "Off":
            tempDevice.state = SceneDeviceModel.StateValues.Off
            break
        default:
            tempDevice.state = SceneDeviceModel.StateValues.Ignore
            break
        }
        
        self.devices?.append(tempDevice)
      }
    }
  }
  
  internal required init(withName: String) {
    self.name = withName
    self.devices = Array<SceneDeviceModel>()
  }
  
  internal func toJson() -> String {
    var json = "{\"name\":\"\(self.name!)\", \"devices\": ["
    
    var first = true
    for device in self.devices! {
      let deviceString = "{\"deviceId\": \"\(device.deviceId!)\", \"state\": \"\(device.state!)\"}"
    
      if first {
        json += deviceString
        first = false
      } else {
        json += "," + deviceString
      }
    }
    
    json += "]}"
    
    return json
  }
}
