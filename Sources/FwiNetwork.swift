//  Project name: FwiCore
//  File name   : FwiNetwork.swift
//
//  Author      : Phuc, Tran Huu
//  Created date: 4/13/14
//  Version     : 1.20
//  --------------------------------------------------------------
//  Copyright © 2012, 2016 Fiision Studio.
//  All Rights Reserved.
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

#if os(iOS)
    import UIKit
#endif
import Foundation


public final class FwiNetwork: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    // MARK: Singleton instance
    public static let instance = FwiNetwork()
    
    // MARK: Class's properties
    public fileprivate (set) lazy var configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default

        // Config request policy
        config.allowsCellularAccess = true
        config.timeoutIntervalForRequest = 60.0
        config.timeoutIntervalForResource = 60.0
        config.networkServiceType = .background

        // Config cache policy
        config.requestCachePolicy = NSURLRequest.CachePolicy.returnCacheDataElseLoad
        return config
    }()

    public fileprivate (set) lazy var session: URLSession = {
        return URLSession(configuration: self.configuration, delegate: self, delegateQueue: operationQueue)
    }()

    fileprivate var networkCounter_ = 0
    public var networkCounter: Int {
        get {
            return networkCounter_
        }
        set {
            objc_sync_enter(networkCounter_); defer { objc_sync_exit(networkCounter_) }
            networkCounter_ = newValue
            #if os(iOS)
                if networkCounter_ > 0 {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                } else {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            #endif
        }
    }

    // MARK: Class's private methods
    /// Output error to console.
    ///
    /// - parameter request (required): request
    /// - parameter data (required): response's data
    /// - parameter error (required): response's error
    /// - parameter statusCode (required): network's status
    internal func consoleError(_ request: URLRequest, data d: Data?, error e: Error?, statusCode s: FwiNetworkStatus) {
        guard let err = e as? NSError, let url = request.url, let host = url.host, let method = request.httpMethod else {
            return
        }
        
        let domain     = "Domain     : \(host)\n"
        let urlString  = "HTTP Url   : \(url)\n"
        let httpMethod = "HTTP Method: \(method)\n"
        let status     = "HTTP Status: \(s.rawValue) (\(err.localizedDescription))\n"
        let dataString = "\(d?.toString() ?? "")"
        
        FwiLog("\n\(domain)\(urlString)\(httpMethod)\(status)\(dataString)")
    }

    /// Generate network error.
    ///
    /// - parameter request (required): request
    /// - parameter statusCode (required): network's status
    internal func generateError(_ request: URLRequest, statusCode s: FwiNetworkStatus) -> NSError {
        let userInfo = [NSURLErrorFailingURLErrorKey:request.url?.description ?? "",
                        NSURLErrorFailingURLStringErrorKey:request.url?.description ?? "",
                        NSLocalizedDescriptionKey:s.description]

        return NSError(domain: NSURLErrorDomain, code: s.rawValue, userInfo: userInfo)
    }

    // MARK: NSURLSessionDelegate's members
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let serverTrust = challenge.protectionSpace.serverTrust, challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        }
        else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    // MARK: NSURLSessionTaskDelegate's members
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(request)
    }
}
