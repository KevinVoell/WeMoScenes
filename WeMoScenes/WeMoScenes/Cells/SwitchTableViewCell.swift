//
//  SwitchTableViewCell.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/12/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {
  
  internal var sceneDeviceModel: SceneDeviceModel?

  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var stateSwitch: UISegmentedControl!

  internal var delegate: SwitchTableViewCellDelegate?

  /**
   * stateSwitchValueChanged: Called when the value of the switch changes.
   */
  @IBAction func stateSwitchValueChanged(sender: AnyObject) {
    sceneDeviceModel!.state = SceneDeviceModel.StateValues(rawValue: self.stateSwitch.selectedSegmentIndex)
  }
  
}
