//
//  ModelBaseExtensions.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/5/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import Foundation
import WeMoInteraction

extension ModelBase {
  public func toJson() -> String {
    return JSONSerializer.toJson(self)
  }
}