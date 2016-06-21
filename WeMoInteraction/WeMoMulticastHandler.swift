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
  var ssdpSocketRec:GCDAsyncUdpSocket!
  
//  let data = "M-SEARCH * HTTP/1.1\r\nContent-Length:0\r\nHOST:239.255.255.250:1900\r\nST: urn:Belkin:device:controllee:1\r\nMX:\r\nMAN:\"ssdp:discover\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)

  /**
   * Delegate called when a device is found.
   */
  weak var delegate: WeMoDiscoveryDelegate?
  
  deinit {
    ssdpSocket.close()
    ssdpSocket = nil
    
    ssdpSocketRec.close()
    ssdpSocketRec = nil
  }
  
  /**
   * Runs the discovery multicast code.
   */
  func start() {
    for i in 0...20
    {
      do
      {
        //send M-Search
        ssdpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        let data = "M-SEARCH * HTTP/1.1\r\nContent-Length:0\r\nHOST:239.255.255.250:1900\r\nST: upnp:rootdevice\r\nMX:\(i)\r\nMAN:\"ssdp:discover\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)
        
        ssdpSocket.sendData(data, toHost: ssdpAddres, port: ssdpPort, withTimeout: 1, tag: 0)
        
        //bind for responses
        try ssdpSocket.bindToPort(ssdpPort)
        try ssdpSocket.joinMulticastGroup(ssdpAddres)
        try ssdpSocket.beginReceiving()
      }
      catch
      {
        // Error
        return
      }
    }
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

