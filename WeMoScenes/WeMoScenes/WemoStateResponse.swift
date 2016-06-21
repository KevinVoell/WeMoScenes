//
//  WemoStatusResponse.swift
//  WemoScenes
//
//  Created by Kevin Voell on 5/29/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import Foundation

internal class WemoStateResponse: NSObject, NSXMLParserDelegate {
  
  internal var status: DeviceModel.DeviceState?
  
  private var parser: NSXMLParser?
  private var inBinaryState = false
  
  init(xml: NSString) {
   
    super.init()
    
    parser = NSXMLParser(data: xml.dataUsingEncoding(NSUTF8StringEncoding)!)
    parser!.delegate = self
    parser!.parse()
  }
  
  func parser(parser: NSXMLParser,
              didStartElement elementName: String,
                              namespaceURI: String?,
                              qualifiedName qName: String?,
                                            attributes attributeDict: [String : String])
  {
    if (elementName == "BinaryState") {
      inBinaryState = true
    }
  }
  
  func parser(parser: NSXMLParser,
              didEndElement elementName: String,
                            namespaceURI: String?,
                            qualifiedName qName: String?)
  {
    if (elementName == "BinaryState") {
      inBinaryState = false
    }
  }
  
  func parser(parser: NSXMLParser,
              foundCharacters string: String)
  {
    status = string == "0" ? DeviceModel.DeviceState.Off : DeviceModel.DeviceState.On
  }
}