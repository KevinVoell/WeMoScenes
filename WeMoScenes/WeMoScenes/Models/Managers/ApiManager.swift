//
//  SceneManager.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/11/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

internal class ApiManager<T: ModelBase> {
  
  /**
   * items: An array of current items.
   */
  internal var items: Array<T> = Array<T>()
  
  /**
   * delegate: The delegate for this instance.
   */
  internal weak var delegate: ManagerDelegate?
  
  /**
   * databaseRef: Reference to the Firebase database.
   */
  private lazy var databaseReference: FIRDatabaseReference = FIRDatabase.database().reference()
  
  /**
   * queryHandle: The handle used for the Firebase query.
   */
  private var queryHandle: UInt?
  
  internal var watching: Bool! = false
  
  private var shutdownListenerObjectProtocol: NSObjectProtocol?
  private var startListenersObjectProtocol: NSObjectProtocol?
  
  /**
   * Deinitializer
   */
  deinit {
    print("deinit called on ApiManager: \(T.tableName!)")
    self.stopWatching()
    
    NSNotificationCenter.defaultCenter().removeObserver(shutdownListenerObjectProtocol!)
    NSNotificationCenter.defaultCenter().removeObserver(startListenersObjectProtocol!)
  }
  
  init() {
    print("init called on ApiManager: \(T.tableName!)")
    
    shutdownListenerObjectProtocol = NSNotificationCenter.defaultCenter().addObserverForName("shutdownListeners", object: nil, queue: nil)
    {
      [unowned self]
      (notification) in
      if self.queryHandle != nil {
        print("Shutting down listeners")
        self.stopWatching()
      }
    }
    
    startListenersObjectProtocol = NSNotificationCenter.defaultCenter().addObserverForName("startListeners", object: nil, queue: nil) {
      [unowned self]
      (notification) in
      if self.queryHandle == nil {
        print("Restarting listeners")
        self.startWatching()
      }
    }
  }
  
  /**
   * exists: Checks if the specified key exists in the database.
   */
  internal func exists(key: String, callback: ((Bool) -> Void)) {
    let existsQuery = self.databaseReference
                          .child(T.tableName!)
                          .child((FIRAuth.auth()?.currentUser!.uid)!)
                          .queryOrderedByKey()
                          .queryEqualToValue(key)
    
    existsQuery.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
      callback(snapshot.exists())
    }) { (error) in
      callback(false)
    }
  }
  
  /** 
   * save: Saves the specified model to the database.
   */
  internal func save(model: T) -> Bool {
    self.databaseReference
      .child(T.tableName!)
      .child((FIRAuth.auth()?.currentUser!.uid)!)
      .child(model.key!)
      .setValue(model.toJson())
    
    return true
  }
  
  /**
   * delete: Deletes the specified model from the database.
   */
  internal func delete(model: T) -> Bool {
    self.databaseReference
      .child(T.tableName!)
      .child((FIRAuth.auth()?.currentUser!.uid)!)
      .child(model.key!)
      .removeValue()
    
    return true
  }
  
  /**
   * startWatching: Start watching for changes to the database.
   */
  internal func startWatching() {
    
    self.watching = true
    
    let query = self.databaseReference
      .child(T.tableName!)
      .child((FIRAuth.auth()?.currentUser!.uid)!)
      .queryOrderedByChild(T.sortKey!)
    
    query.keepSynced(true)
    
    self.queryHandle = query.observeEventType(FIRDataEventType.Value, withBlock: {
      [unowned self]
      (data) in
      
      if !(data.value is NSNull) {
        
        self.items.removeAll()
        
        let dict = data.value as! [String: String]

        for item in dict.values {
          let obj = T(fromJSON: item)
          self.items.append(obj)
        }
        
        self.items.sortInPlace({ (model1, model2) -> Bool in
          return model1.key < model2.key
        })
      } else {
        self.items.removeAll()
      }
      
      self.delegate?.itemAdded()
    })
  }
  
  /**
   * stopWatching: Stop watching for changes to the database.
   */
  internal func stopWatching() {
    self.watching = false
    
    if queryHandle != nil {
      self.databaseReference.removeObserverWithHandle(queryHandle!)
      queryHandle = nil
    }
  }
  
}
