//
//  CredifySdkManager.swift
//  example059
//
//  Created by Danh Nguyen Ngoc on 27/07/2021.
//  Copyright © 2021 Facebook. All rights reserved.
//

@objc(CredifySdkManager)
class CredifySdkManager: NSObject {

  @objc(addEvent:)
  func addEvent(name: String) -> Void {
    // Date is ready to use!
    NSLog("Credify Event added is " + name)
  }

}
