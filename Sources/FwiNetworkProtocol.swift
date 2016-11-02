//  Project name: FwiCore
//  File name   : FwiNetworkProtocol.swift
//
//  Author      : Phuc, Tran Huu
//  Created date: 10/31/16
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2016 Fiision Studio. All rights reserved.
//  --------------------------------------------------------------

import Foundation


public protocol FwiNetworkProtocol {
    typealias RequestCompletion = (_ data: Data?, _ error: Error?, _ statusCode: FwiNetworkStatus, _ response: HTTPURLResponse?) -> Void
    typealias DownloadCompletion = (_ location: URL?, _ error: Error?, _ statusCode: FwiNetworkStatus, _ response: HTTPURLResponse?) -> Void
}


public extension FwiNetworkProtocol {

    /// Download resource from server.
    ///
    /// - parameter request (required): request
    /// - parameter completion (required): call back function
    @discardableResult
    public func download(resource r: URLRequest, completion c: @escaping DownloadCompletion) -> URLSessionDownloadTask {
        // Turn on activity indicator
        let manager = FwiNetwork.instance
        manager.networkCounter += 1

        // Create new task
        let task = manager.session.downloadTask(with: r) { (location, response, err) in
            // Turn off activity indicator if neccessary
            manager.networkCounter -= 1
            var error = err
            
            var statusCode = FwiNetworkStatus.unknown
            if let error = error as? NSError {
                statusCode = FwiNetworkStatus(rawValue: error.code)
            }
            
            /* Condition validation: Validate HTTP response instance */
            guard let httpResponse = response as? HTTPURLResponse else {
                c(nil, error, statusCode, nil)
                return
            }
            statusCode = FwiNetworkStatus(rawValue: httpResponse.statusCode)
            
            // Validate HTTP status
            if !FwiNetworkStatusIsSuccces(statusCode) {
                error = manager.generateError(r as URLRequest, statusCode: statusCode)
            }
            manager.consoleError(r, data: nil, error: error, statusCode: statusCode)
            c(location, error, statusCode, httpResponse)
        }

        task.resume()
        return task
    }
    
    // MARK: Class's public methods
    /// Send request to server.
    ///
    /// - parameter request (required): request
    /// - parameter completion (required): call back function
    @discardableResult
    public func send(request r: URLRequest, completion c: @escaping RequestCompletion) -> URLSessionDataTask {
        // Turn on activity indicator
        let manager = FwiNetwork.instance
        manager.networkCounter += 1
        
        // Create new task
        let task = manager.session.dataTask(with: r) { (data, response, err) in
            // Turn off activity indicator if neccessary
            manager.networkCounter -= 1
            var error = err
            
            var statusCode = FwiNetworkStatus.unknown
            if let error = error as? NSError {
                statusCode = FwiNetworkStatus(rawValue: error.code)
            }

            /* Condition validation: Validate HTTP response instance */
            guard let httpResponse = response as? HTTPURLResponse else {
                c(nil, error, statusCode, nil)
                return
            }
            statusCode = FwiNetworkStatus(rawValue: httpResponse.statusCode)
            
            // Validate HTTP status
            if !FwiNetworkStatusIsSuccces(statusCode) {
                error = manager.generateError(r as URLRequest, statusCode: statusCode)
            }
            manager.consoleError(r, data: data, error: error, statusCode: statusCode)
            c(data, error, statusCode, httpResponse)
        }
        task.resume()
        return task
    }
    
    /// Cancel all running Tasks.
    public func cancelTasks() {
        let manager = FwiNetwork.instance

        if #available(OSX 10.11, iOS 9.0, *) {
            manager.session.getAllTasks { (tasks) in
                tasks.forEach({
                    $0.cancel()
                })
            }
        } else {
            manager.session.getTasksWithCompletionHandler({ (sessionTasks, uploadTasks, downloadTasks) in
                sessionTasks.forEach({
                    $0.cancel()
                })
                
                uploadTasks.forEach({
                    $0.cancel()
                })
                
                downloadTasks.forEach({
                    $0.cancel()
                })
            })
        }
    }
    
    /// Cancel all data Tasks.
    public func cancelDataTasks() {
        let manager = FwiNetwork.instance
        manager.session.getTasksWithCompletionHandler({ (sessionTasks, _, _) in
            sessionTasks.forEach({
                $0.cancel()
            })
        })
    }
    
    /// Cancel all download Tasks.
    public func cancelDownloadTasks() {
        let manager = FwiNetwork.instance
        manager.session.getTasksWithCompletionHandler({ (_, _, downloadTasks) in
            downloadTasks.forEach({
                $0.cancel()
            })
        })
    }
    
    /// Cancel all upload Tasks.
    public func cancelUploadTasks() {
        let manager = FwiNetwork.instance
        manager.session.getTasksWithCompletionHandler({ (_, uploadTasks, _) in
            uploadTasks.forEach({
                $0.cancel()
            })
        })
    }
}