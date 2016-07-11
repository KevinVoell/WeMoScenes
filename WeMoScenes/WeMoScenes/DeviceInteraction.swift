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
import CCActivityHUD

public class DeviceInteraction : Interaction, WeMoDiscoveryDelegate {
  
  let port = 49153
  
  static let soapActionBase = "urn:Belkin:service:basicevent:1#"
  
  static let soapCommandStart = "<?xml version='1.0' encoding='utf-8'?><s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'><s:Body>"
  
  static let soapCommandEnd = "</s:Body></s:Envelope>"
  
  //private var discovery: WeMoMulticastHandler?
  
  internal var devices: Array<DeviceModel> = Array<DeviceModel>()
  
  private var databaseReference: FIRDatabaseReference!
  
  class var sharedInstance: DeviceInteraction {
    struct Singleton {
      static let instance = DeviceInteraction()
    }
    
    return Singleton.instance
  }
  
  private init() {
    print("Called init on DeviceInteraction")
  
    self.databaseReference = FIRDatabase.database().reference()    
  }
  
  deinit {
    print("Called deinit on DeviceInteraction")
    
    WeMoMulticastHandler.sharedInstance.close()
  }
  
  /**
   * Delegate
   */
  public var delegate: InteractionDelegate?
  
  /*
   * Gets the stat of the device
   */
  static internal func getState(device: DeviceModel, completion: (DeviceModel.DeviceState?) -> ()) {
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
  
  static let v = CCActivityHUD()
  
  internal static func setState(device: DeviceModel, state: DeviceModel.DeviceState) {
    
    v.showWithType(.ArcInCircle)
    
    let soapAction = "\"\(soapActionBase)SetBinaryState\""
    
    let intState = state == DeviceModel.DeviceState.On ? 1 : 0
    
        let command = "\(soapCommandStart)<u:SetBinaryState xmlns:u='urn:Belkin:service:basicevent:1'><BinaryState>\(intState)</BinaryState></u:SetBinaryState>\(soapCommandEnd)"
    
        self.sendCommand(device, withSoapAction: soapAction, andSoapCommand: command) {
          error, response in
    
          if error != nil {
            // Oops something happened
            print(error?.localizedDescription)
            
            NSThread.sleepForTimeInterval(1)
            dispatch_async(dispatch_get_main_queue(),{
              v.dismissWithText("", delay: 1, success: false)
            })
            
            return;
          }
          
          let responseString = String(data: response!, encoding: NSUTF8StringEncoding)
          let parsedResponse = WemoStateResponse(xml: responseString!)
          print(parsedResponse)
          
          NSThread.sleepForTimeInterval(1)
          dispatch_async(dispatch_get_main_queue(),{
            v.dismiss()
          })
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
        let device = DeviceModel.init(fromXML: xml!)
        
        if (!device.aborted) {
          print(device.friendlyName!)
          
          device.ipAddress = baseAddress.stringByReplacingOccurrencesOfString("/setup.xml", withString: "")
          
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
  internal func findDevices() -> Array<DeviceModel> {
    let devices = Array<DeviceModel>()
    
    if WeMoMulticastHandler.sharedInstance.delegate == nil {
      WeMoMulticastHandler.sharedInstance.delegate = self
    }
    
    //WeMoMulticastHandler.sharedInstance.close()()
    WeMoMulticastHandler.sharedInstance.findDevices()
    
    return devices
  }
  
  /**
   * Gets the NSURLRequest object for a device.
   *
   * @param forDevice The device to get the request object for.
   *
   * @return NSURLRequest The request object.
   */
  private static func getUrlRequest(forDevice: DeviceModel) -> NSMutableURLRequest {
    let myUrl = NSURL(string: "\(forDevice.ipAddress!)/upnp/control/basicevent1")
    
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
  private static func sendCommand(toDevice: DeviceModel,
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
