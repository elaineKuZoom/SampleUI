//
//  File.swift
//  SampleUI
//
//  Created by Elaine Ku on 10/14/25.
//

import UIKit
import SampleUIObjC

@_exported import SampleUIObjC  // so consumers can just `import SampleUI`

public enum SampleUIEntry {
  public static func makeRootViewController() -> UIViewController {
    return SampleUIBootstrap.makeRootViewController()
  }
  public static var bundle: Bundle { .module }   // use for storyboards/images if needed
}
