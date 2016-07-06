//
//  AppDelegate.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/3/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  /**
   * manager: Data manager for the device table.
   */
  internal static var deviceModelManager: ApiManager<DeviceModel>?
  
  private var connectionsRunning: Bool! = false

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.

    Chameleon.setGlobalThemeUsingPrimaryColor(UIColor.flatSkyBlueColor(), withContentStyle: UIContentStyle.Light)

    // Configure FireBase
    FIRApp.configure()
    FIRAuth.auth()?.addAuthStateDidChangeListener(self.handleAuthChange)
    
    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    self.closeNetworkConnections()
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //resumeNetworkConnections()
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    
    self.closeNetworkConnections()
  }
  
  func handleAuthChange(auth: FIRAuth?, user : FIRUser?) {
    if user == nil {
      self.closeNetworkConnections()
    } else {
      self.resumeNetworkConnections()
    }
  }
  
  func resumeNetworkConnections() {
    if !self.connectionsRunning {
      self.connectionsRunning = true
      
      print("Starting network connections")
      //WeMoMulticastHandler.sharedInstance.findDevices()
      NSNotificationCenter.defaultCenter().postNotificationName("startListeners", object: nil)
    }
  }
  
  func closeNetworkConnections() {
    print("Stopping network connections")
    
    WeMoMulticastHandler.sharedInstance.close()
    
    // TODO: Shutdown other connections
    NSNotificationCenter.defaultCenter().postNotificationName("shutdownListeners", object: nil)
    
    self.connectionsRunning = false
  }

}

