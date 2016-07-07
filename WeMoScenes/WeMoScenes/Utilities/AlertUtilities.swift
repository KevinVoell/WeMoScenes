//
//  AlertUtilities.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 7/5/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import UIKit

internal extension UIViewController {
  
  /**
    Show an alert on the specified UIViewController.
  */
  internal func showAlert(title: String,
                        message: String,
             dismissButtonTitle: String,
              completionHandler: ((Void) -> Void)?,
              additionalButtons: Array<(title: String, handler: (UIAlertAction) -> Void)>?){
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    
    // Add the dismiss button by default
    alert.addAction(UIAlertAction(title: dismissButtonTitle, style: .Cancel, handler: nil))
    
    if additionalButtons != nil {
      for additionalButton in additionalButtons! {
        alert.addAction(UIAlertAction(title: additionalButton.title, style: .Default, handler: additionalButton.handler))
      }
    }

    self.presentViewController(alert, animated: true, completion: completionHandler)
  }
}
