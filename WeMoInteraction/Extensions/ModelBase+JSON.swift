//
//  ModelBase+JSON.swift
//  WeMoInteraction
//
//  Created by Kevin Voell on 6/9/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import Foundation

extension ModelBase {
  public func toJson() -> String {
    return JSONSerializer.toJson(self)
  }
}