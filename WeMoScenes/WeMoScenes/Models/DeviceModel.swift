//
//  Device.swift
//  WeMoInteraction
//
//  Created by Kevin Voell on 6/4/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import Foundation
import SwiftyJSON

internal class DeviceModel : NSObject, ModelBase, NSXMLParserDelegate {
  
  static var tableName: String? {
    get { return "Devices" }
  }
  
  static var sortKey: String? {
    get { return "friendlyName" }
  }
  
  /** 
   * The possible device states a WeMo device could be in.
   */
  internal enum DeviceState {
    case On
    case Off
  }
  
  var key: String? {
    return UDN
  }
  
  /**
   * The name of the device.
   */
  internal var friendlyName: String?
  
  /**
   * The type of device.
   */
  internal var deviceType: String?
  
  /**
   * The serial number of the device.
   */
  internal var serialNumber: String?
  
  /**
   * The firmware version of the device.
   */
  internal var firmwareVersion: String?
  
  /**
   * The local IP address of the device
   */
  internal var ipAddress: String?
  
  /**
   * The port the device is listening on.
   */
  internal var port: String?
  
  internal var UDN: String?
  
  internal var aborted: Bool = false
  
  private var inRoot: Bool = false
  
  private var inDevice: Bool = false
  
  private var subElementName: String = ""
  
  internal override init() {
    
  }
  
  internal required convenience init(fromJSON: String ) {
    self.init()

    if let dataFromString = fromJSON.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
      let json = JSON(data: dataFromString)
      
      self.friendlyName = json["friendlyName"].stringValue
      self.serialNumber = json["serialNumber"].stringValue
      self.ipAddress = json["ipAddress"].stringValue
      self.UDN = json["UDN"].stringValue
    }
    
    // TODO: Initialize
    
  }
  
  internal convenience init(fromXML: String) {
    self.init()
    
    let parser = NSXMLParser(data: fromXML.dataUsingEncoding(NSUTF8StringEncoding)!)
    parser.delegate = self
    parser.shouldProcessNamespaces = true
    parser.parse()
  }
  
  internal func on() {
    DeviceInteraction.setState(self, state: .On)
  }
  
  internal func off() {
    DeviceInteraction.setState(self, state: .Off)
  }
  
  internal func toJson() -> String {
    return JSONSerializer.toJson(self)
  }
  
  internal func parser(parser: NSXMLParser,
              didStartElement elementName: String,
                              namespaceURI: String?,
                              qualifiedName qName: String?,
                                            attributes attributeDict: [String : String])
  {
    if (!(namespaceURI?.hasPrefix("urn:Belkin:"))!){
      self.aborted = true
      parser.abortParsing()
      return;
    }
    
    switch elementName {
    case "root":
      self.inRoot = true
    case "device":
      self.inDevice = true
    default:
      if (inRoot && inDevice) {
        self.subElementName = elementName
      }
    }
  }
  
  internal func parser(parser: NSXMLParser,
              didEndElement elementName: String,
                            namespaceURI: String?,
                            qualifiedName qName: String?)
  {
    switch elementName {
    case "root":
      self.inRoot = false
    case "device":
      self.inDevice = false
    default:
      if (inRoot && inDevice) {
        self.subElementName = ""
      }
    }
  }
  
  internal func parser(parser: NSXMLParser,
              foundCharacters string: String)
  {
    if (inRoot && inDevice) {
      switch self.subElementName {
      case "friendlyName":
        self.friendlyName = string
      case "serialNumber":
        self.serialNumber = string
      //case "binaryState":
      //  self.status = string == "0" ? WemoState.Off : WemoState.On
      case "firmwareVersion":
        self.firmwareVersion = string
      case "UDN":
        self.UDN = string
      default: break
        
      }
    }
  }
}
