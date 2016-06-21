//
//  Interaction.swift
//  WemoScenes
//
//  Created by Kevin Voell on 5/29/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import Foundation

public protocol Interaction {
  
  //static func instance() -> Interaction
  
  func getState(device: DeviceDataModel, completion: (deviceState?) -> ())
  
  func setState(device: DeviceDataModel, state: deviceState)
  
  func findDevices() -> Array<DeviceDataModel>
}