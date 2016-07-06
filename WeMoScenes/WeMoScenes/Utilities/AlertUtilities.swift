//
//  AlertUtilities.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 7/5/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import UIKit

extension UIViewController {
  /**
    Show an alert on the specified UIViewController.
  */
  func ShowALert(title: String, 
                               message: String, 
                               viewController: UIViewController
                               dismissButtonTitle: String
                               additionalButtonTitle: String?
                               additionalButtonCompletionHandler: ((Void) -> Void)?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    
    // Add the dismiss button by default
    alert.addAction(UIAlertAction(title: dismissButtonTitle, style: .Cancel, handler: nil))
    
    if additionalButtonTitle != nil {
      // Add additional button
      alert.addAction(UIAlertAction(title: additionalButtonTitle, style: .Default, handler: additionalButtonCompletionHandler))
    }
    
     viewController.presentViewController(alert, animated: true, completion: nil)
  }
}
