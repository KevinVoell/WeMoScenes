//
//  Array+Find.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/22/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import Foundation

extension Array {
  
  // Returns the first element satisfying the predicate, or `nil`
  // if there is no matching element.
  func findFirstMatching<L : BooleanType>(predicate: Element -> L) -> Element? {
    for item in self {
      if predicate(item) {
        return item // found
      }
    }
    return nil // not found
  }
}
