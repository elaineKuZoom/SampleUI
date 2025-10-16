//
//  File.swift
//  SampleUI
//
//  Created by Elaine Ku on 10/15/25.
//

import UIKit
import SampleUIObjC   // Swift target can import Obj-C target

public enum SampleUIEntry {
    public static func makeRootViewController() -> UIViewController {
        // Inject the SwiftPM bundle so Obj-C can load resources
        SampleUISetResourcesBundle(Bundle.module)

        let intro = IntroduceViewController()
        return BaseNavigationController(rootViewController: intro)
    }
}
