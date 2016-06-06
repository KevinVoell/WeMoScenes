//
//  WeMoDiscoveryDelegate.swift
//  WeMoInteraction
//
//  Created by Kevin Voell on 6/2/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import Foundation

internal protocol WeMoDiscoveryDelegate : class {
  
  /**
   * Called when a new device is discovered.
   *
   * @param ipAddress the IP address of the device.
   * @param withXML the discovery XML returned by the device.
  */
  func deviceDiscoveredAt(ipAddress: String, withXML: String)
  
}
