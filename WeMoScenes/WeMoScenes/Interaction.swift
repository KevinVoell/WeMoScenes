//
//  Interaction.swift
//  WemoScenes
//
//  Created by Kevin Voell on 5/29/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import Foundation

internal protocol Interaction {
  
  static func getState(device: DeviceModel, completion: (DeviceModel.DeviceState?) -> ())
  
  static func setState(device: DeviceModel, state: DeviceModel.DeviceState)
  
  func findDevices() -> Array<DeviceModel>
}