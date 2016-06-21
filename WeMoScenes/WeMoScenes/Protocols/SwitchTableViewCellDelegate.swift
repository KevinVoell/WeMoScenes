//
//  SwitchTableViewCellDelegate.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/13/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import Foundation

internal protocol SwitchTableViewCellDelegate : class {
  func switchValue(changedTo: Bool, forSceneViewModel: SceneDeviceModel)
}