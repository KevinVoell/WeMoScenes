//
//  WeMoMulticastHandler.swift
//  WeMoInteraction
//
//  Created by Kevin Voell on 6/2/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

class WeMoMulticastHandler : GCDAsyncUdpSocketDelegate {
  
  var ssdpAddres          = "239.255.255.250"
  var ssdpPort:UInt16     = 1900
  var ssdpSocket:GCDAsyncUdpSocket!
  var connected           = false
  
  let data = "M-SEARCH * HTTP/1.1\r\n"
             + "Content-Length:0\r\n"
             + "HOST:239.255.255.250:1900\r\n"
             + "ST: upnp:rootdevice\r\n"
             + "MX:2\r\n"
             + "MAN:\"ssdp:discover\"\r\n"
             + "\r\n"
  
  var datagram: NSData!
  
  /**
   * Delegate called when a device is found.
   */
  weak var delegate: WeMoDiscoveryDelegate?
  
  private struct Singleton {
    private static var instance: WeMoMulticastHandler?
    
    private static func Instance() -> WeMoMulticastHandler {
      if instance == nil {
        instance = WeMoMulticastHandler()
      }
      
      return instance!
    }
  }
  
  class var sharedInstance: WeMoMulticastHandler {
    return Singleton.Instance()
  }
  
  private init() {
    print("init called on WeMoMulticastHandler")
    
    ssdpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
    
    do {        
      //bind for responses
      try ssdpSocket.bindToPort(ssdpPort)
      try ssdpSocket.joinMulticastGroup(ssdpAddres)
      try ssdpSocket.beginReceiving()
    }
    catch let unknownError
    {
      // Error
      print(unknownError)
    }
    
    self.datagram = data.dataUsingEncoding(NSUTF8StringEncoding)
  }
  
  deinit {
    print("Deinit called on WeMoMulticastHandler")
    
    if ssdpSocket != nil {
      ssdpSocket.close()
      ssdpSocket = nil
    }
  }
  
  /**
   * Runs the discovery multicast code.
   */
  func findDevices() {
    ssdpSocket.sendData(datagram, toHost: ssdpAddres, port: ssdpPort, withTimeout: 1, tag: 0)
  }
  
  func close() {
    Singleton.instance = nil
//    if ssdpSocket != nil {
//      ssdpSocket.close()
//      ssdpSocket = nil
//    }
  }
  
  /**
   * Called when the socket has received the requested datagram.
   **/
  @objc func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
    
    var host: NSString?
    var port1: UInt16 = 0
    GCDAsyncUdpSocket.getHost(&host, port: &port1, fromAddress: address)

    let gotdata: String = String(data: data!, encoding: NSUTF8StringEncoding)!

    var location: String?
    var isBelkin: Bool = false
    
    gotdata.enumerateLines { (line, stop) in
//      if (line.uppercaseString.hasPrefix("ST: URN:BELKIN")) {
        isBelkin = true
//      }
      if (line.uppercaseString.hasPrefix("LOCATION: ")) {
        location = line.substringFromIndex(line.startIndex.advancedBy(10))
      }
    }
    
    if (isBelkin && location != nil) {
      self.delegate?.deviceDiscoveredAt(location!, withXML: gotdata)
    }
  }
  
  /**
   * By design, UDP is a connectionless protocol, and connecting is not needed.
   * However, you may optionally choose to connect to a particular host for reasons
   * outlined in the documentation for the various connect methods listed above.
   *
   * This method is called if one of the connect methods are invoked, and the connection is successful.
   **/
  @objc func udpSocket(sock:GCDAsyncUdpSocket!,didConnectToAddress data : NSData!){
    print("didConnectToAddress")
    print(NSString(data: data, encoding: NSUTF8StringEncoding))
  }
}

