//  File name   : Localization.swift
//
//  Author      : Phuc Tran
//  Editor      : Dung Vu
//  Created date: 4/13/15
//  --------------------------------------------------------------
//  Copyright © 2012, 2019 Fiision Studio. All Rights Reserved.
//  --------------------------------------------------------------
//
//  Permission is hereby granted, free of charge, to any person obtaining  a  copy
//  of this software and associated documentation files (the "Software"), to  deal
//  in the Software without restriction, including without limitation  the  rights
//  to use, copy, modify, merge,  publish,  distribute,  sublicense,  and/or  sell
//  copies of the Software,  and  to  permit  persons  to  whom  the  Software  is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF  ANY  KIND,  EXPRESS  OR
//  IMPLIED, INCLUDING BUT NOT  LIMITED  TO  THE  WARRANTIES  OF  MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO  EVENT  SHALL  THE
//  AUTHORS OR COPYRIGHT HOLDERS  BE  LIABLE  FOR  ANY  CLAIM,  DAMAGES  OR  OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING  FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN  THE
//  SOFTWARE.
//
//
//  Disclaimer
//  __________
//  Although reasonable care has been taken to  ensure  the  correctness  of  this
//  software, this software should never be used in any application without proper
//  testing. Fiision Studio disclaim  all  liability  and  responsibility  to  any
//  person or entity with respect to any loss or damage caused, or alleged  to  be
//  caused, directly or indirectly, by the use of this software.

import Foundation

public final class Localization {
    /// Class's public properties.
    var locale: String {
        didSet {
            let currentLocale = self.locale
            guard
                let path = Bundle.main.path(forResource: currentLocale, ofType: "lproj"),
                let bundle = Bundle(path: path)
            else {
                reset()
                return
            }

            // Update bundle's prefer language for next time usage
            let userDefaults = UserDefaults.standard
            userDefaults.set([currentLocale], forKey: "AppleLanguages")
            userDefaults.synchronize()

            self.bundle = bundle
        }
    }

    /// Class's constructors.
    public init() {
        let preferredLocalizations = Bundle.main.preferredLocalizations
        let mostPreferable = execution { preferredLocalizations.first }.orNil("en")

        self.locale = mostPreferable
    }

    /// Class's private properties.
    private var bundle: Bundle = .main
}

// MARK: - Struct's public methods
public extension Localization {
    func localized(_ text: String) -> String {
        return bundle.localizedString(forKey: text, value: text, table: nil)
    }

    /// Reset locale to most prefer localization.
    func reset() {
        let languages = bundle.preferredLocalizations
        let next = languages.first.orNil("en")

        guard locale != next else { return }
        locale = next
    }
}
