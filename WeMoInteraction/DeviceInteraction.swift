//
//  Interaction.swift
//  WemoInteraction
//
//  Created by Kevin Voell on 5/29/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import Foundation
import SystemConfiguration
import Firebase

public class DeviceInteraction : Interaction, WeMoDiscoveryDelegate {
  
  let port = 49153
  
  let soapActionBase = "urn:Belkin:service:basicevent:1#"
  
  let soapCommandStart = "<?xml version='1.0' encoding='utf-8'?><s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'><s:Body>"
  
  let soapCommandEnd = "</s:Body></s:Envelope>"
  
  private var discovery: WeMoMulticastHandler?
  
  public var devices: Array<DeviceDataModel> = Array<DeviceDataModel>()
  
  private var databaseReference: FIRDatabaseReference!
  
  public init() {
    // Configure FireBase
    FIRApp.configure()
    
    FIRAuth.auth()?.signInAnonymouslyWithCompletion() { (user, error) in
      self.databaseReference = FIRDatabase.database().reference()
    }
    
    
  }
  
  deinit {
    discovery = nil
  }
  
  /**
   * Delegate
   */
  public var delegate: InteractionDelegate?
  
  /*
   * Gets the stat of the device
   */
  public func getState(device: DeviceDataModel, completion: (deviceState?) -> ()) {
    let soapAction = "\"\(soapActionBase)GetBinaryState\""
    
    let command = "\(soapCommandStart)<u:GetBinaryState xmlns:u='urn:Belkin:service:basicevent:1'><BinaryState>1</BinaryState></u:GetBinaryState>\(soapCommandEnd)"
    
    self.sendCommand(device, withSoapAction: soapAction, andSoapCommand: command) {
      error, response in
      
      if error != nil {
        // Oops something happened
        
        return;
      }
      
      let responseString = String(data: response!, encoding: NSUTF8StringEncoding)
      let parsedResponse = WemoStateResponse(xml: responseString!)
      
      completion(parsedResponse.status)
    }
  }
  
  public func setState(device: DeviceDataModel, state: deviceState) {
        let soapAction = "\(soapActionBase)SetBinaryState"
    
    
        self.sendCommand(device, withSoapAction: soapAction, andSoapCommand: "") {
          error, response in
    
          if error != nil {
            // Oops something happened
    
            return;
          }
        }
  }
  
  public func getDevice(baseAddress: String) {
    let myUrl = NSURL(string: baseAddress)

    let request = NSMutableURLRequest(URL:myUrl!)
    request.HTTPMethod = "GET"
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
      data, response, error in
      
      if (data != nil) {
        let xml = String(data: data!, encoding: NSUTF8StringEncoding)
        let device = DeviceDataModel.init(fromXML: xml!)
        
        if (!device.aborted) {
          print(device.friendlyName!)
          
          device.ipAddress = baseAddress.stringByReplacingOccurrencesOfString("/setup.xml", withString: "")
          let currentUser = FIRAuth.auth()
          
          self.databaseReference.child("Devices")
            .child((FIRAuth.auth()?.currentUser!.uid)!)
            .child(device.UDN!)
            .setValue(device.toJson())
        }
      }
    }
    
    task.resume()
  }
  
  /**
   * Find WeMo devices that are on the same network.
   *
   * @param baseAddress the local IP address to find devices on.
   *
   * @return Array<Device> An array of devices found.
   */
  public func findDevices() -> Array<DeviceDataModel> {
    let devices = Array<DeviceDataModel>()
    
    discovery = WeMoMulticastHandler();
    discovery?.delegate = self
    discovery!.start()
    
    return devices
  }
  
  /**
   * Gets the NSURLRequest object for a device.
   *
   * @param forDevice The device to get the request object for.
   *
   * @return NSURLRequest The request object.
   */
  private func getUrlRequest(forDevice: DeviceDataModel) -> NSMutableURLRequest {
    let myUrl = NSURL(string: "http://\(forDevice.ipAddress):\(forDevice.port)/upnp/control/basicevent1")
    
    let request = NSMutableURLRequest(URL:myUrl!)
    
    // set common request values
    request.addValue("text/xml; charset=\"utf-8\"", forHTTPHeaderField: "Content-type")
    request.addValue("", forHTTPHeaderField: "Accept")
    request.HTTPMethod = "POST"
    
    return request
  }

  
  /*
   * Send the command and wait for the reponse.
   */
  private func sendCommand(toDevice: DeviceDataModel,
                           withSoapAction: String,
                           andSoapCommand: String,
                           completion: (NSError?, NSData?) -> ()) {
    
    let request = self.getUrlRequest(toDevice)
    
    request.addValue(withSoapAction, forHTTPHeaderField: "SOAPACTION")
    request.HTTPBody = andSoapCommand.dataUsingEncoding(NSASCIIStringEncoding)
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
      data, response, error in
      
      completion(error, data)
    }
    
    task.resume()
  }
  
  /**
   * Called when a new device is discovered.
   *
   * @param ipAddress the IP address of the device.
   * @param withXML the discovery XML returned by the device.
   */
  internal func deviceDiscoveredAt(ipAddress: String, withXML: String) {
    self.getDevice(ipAddress)
  }
}