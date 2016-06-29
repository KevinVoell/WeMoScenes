//
//  SceneTableViewCell.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/21/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import UIKit

internal class SceneTableViewCell: UITableViewCell {

  internal var scene: SceneModel?
  
  internal var device: DeviceModel?
  
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var onOffButton: UISegmentedControl!
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    scene = nil
    device = nil
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    //(onOffButton.subviews[1] as UIView).backgroundColor = UIColor.flatGreenColor()
    //(onOffButton.subviews[1] as UIView).tintColor = UIColor.blackColor()
    
    //(onOffButton.subviews[0] as UIView).backgroundColor = UIColor.flatRedColor()
    //(onOffButton.subviews[0] as UIView).tintColor = UIColor.blackColor()
    
//    NSFontAttributeName:[UIFont fontWithName:@"Arial" size:16.0],
//    NSForegroundColorAttributeName:[UIColor redColor],
//    NSShadowAttributeName:shadow}
  
    
  
    onOffButton.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.blackColor()], forState: UIControlState.Selected)
  }
  
  @IBAction func Test(sender: AnyObject) {
    switch (onOffButton.selectedSegmentIndex) {
    case 0:
      if device != nil {
        device?.on()
        return
      }
      
      if self.scene?.name == "All Switches" {
        for device in (AppDelegate.deviceModelManager?.items)! {
          device.on()
        }
      }  else {
        
        for device in (self.scene?.devices)! {
          
          if let realDevice = (AppDelegate.deviceModelManager?.items)?.findFirstMatching({$0.UDN == device.deviceId}) {
            
            if device.state == SceneDeviceModel.StateValues.On  {
              realDevice.on()
            } else if device.state == SceneDeviceModel.StateValues.Off {
              realDevice.off()
            }
          }
        }
      }
      break
      
    default:
      if device != nil {
        device?.off()
        return
      }
      
      if self.scene?.name == "All Switches" {
        for device in (AppDelegate.deviceModelManager?.items)! {
          device.off()
        }
      } else {
        
        for device in (self.scene?.devices)! {
          
          if let realDevice = (AppDelegate.deviceModelManager?.items)?.findFirstMatching({$0.UDN == device.deviceId}) {
            if device.state == SceneDeviceModel.StateValues.On || device.state == SceneDeviceModel.StateValues.Off  {
              realDevice.off()
            }
          }
        }
      }
      break
    }
  }
}
