//
//  Device.swift
//  WeMoInteraction
//
//  Created by Kevin Voell on 6/4/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import Foundation

public class DeviceDataModel : NSObject, ModelBase, NSXMLParserDelegate {
  
  /**
    The name of the device.
  */
  public var friendlyName: String?
  
  /**
    The type of device.
  */
  public var deviceType: String?
  
  /**
    The serial number of the device.
  */
  public var serialNumber: String?
  
  /**
    The firmware version of the device.
  */
  public var firmwareVersion: String?
  
  /**
    The local IP address of the device.
   */
  public var ipAddress: String?
  
  /**
    The port the device is listening on.
   */
  public var port: String?
  
  public var UDN: String?
  
  /**
    Indicates if the parsing was aborted.
  */
  public var aborted: Bool = false
  
  private var inRoot: Bool = false
  
  private var inDevice: Bool = false
  
  private var subElementName: String = ""
  
  public override init() {
    
  }

  /**
    init: Initializes an instance of the Device class from Xml.
    
    - parameter fromXML String: The Xml to initialize this class from.
  */
  public convenience init(fromXML: String) {
    self.init()
    
    let parser = NSXMLParser(data: fromXML.dataUsingEncoding(NSUTF8StringEncoding)!)
    parser.delegate = self
    parser.shouldProcessNamespaces = true
    parser.parse()
  }
  
  public func parser(parser: NSXMLParser,
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
  
  public func parser(parser: NSXMLParser,
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
  
  public func parser(parser: NSXMLParser,
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
