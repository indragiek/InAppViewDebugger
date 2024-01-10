//
//  Bundle+Extension.swift
//  
//
//  Created by Robert Powell on 7/14/20.
//

import Foundation

extension Bundle {
    /// Returns a bundle for a class or from a package included from Swift Package Manager
    ///
    /// This initializer makes use of some details from an Xcode beta that may be subject to change.
    /// Do not use this initializer for classes that are defined in your application.
    ///
    ///     Parameters:
    ///     -aClass: A class
    ///     -package: The name of the directory that corresponds to your framework included by Swift Package Manager.
    public convenience init?(for aClass: AnyClass, in package: String) {
        let bundle: Bundle?

        let mysteryBundle = Bundle(for: aClass)
        if let location = mysteryBundle.bundlePath.range(of: ".app"),
           location.upperBound == mysteryBundle.bundlePath.endIndex {
            //Runtime has returned the main Bundle, not the framework bundle
            //Runtime has returned the main Bundle, not the framework bundle
            if let path = mysteryBundle.path(forResource: package, ofType: "bundle") {
                bundle = Bundle(path: path)
            } else {
                assert(false, "A nonexistent package was specified.  Check \(mysteryBundle.bundlePath) for correct name of package")
                bundle = nil
            }
        } else {
            bundle = mysteryBundle
        }

        if let path = bundle?.bundlePath {
            self.init(path: path)
        } else {
            return nil
        }
    }
}
