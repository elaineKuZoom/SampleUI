//
//  File.swift
//  SampleUI
//
//  Created by Elaine Ku on 10/15/25.
//

import UIKit

@objc public final class SampleUIBundleHelper: NSObject {
    @objc public static var bundle: Bundle { .module }

    @objc public static func imageNamed(_ name: String) -> UIImage? {
        UIImage(named: name, in: .module, compatibleWith: nil)
    }
}
