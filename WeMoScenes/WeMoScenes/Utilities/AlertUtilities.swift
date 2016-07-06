//
//  AlertUtilities.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 7/5/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import UIKit

internal class AlertUtilities {
  internal static func ShowALert(title: String, message: String, viewController: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    
    alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
    
     viewController.presentViewController(alert, animated: true, completion: {
    })
  }
}
