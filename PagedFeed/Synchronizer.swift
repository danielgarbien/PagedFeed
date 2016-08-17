//
//  Synchronizer.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 31/05/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

enum SynchronizerResult<Result> {
    case Success(Result)
    case NoData
    case Error(ErrorType) /// Might be SynchronizerError or parsing error thrown by Resource
}

enum SynchronizerError: ErrorType {
    case WrongStatusError(status: Int)
    case URLSessionError(NSError)
}

class Synchronizer {
    
    private lazy var session: NSURLSession! = NSURLSession(
        configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
        delegate: SessionDelegate(cacheTime: self.cacheTime),
        delegateQueue: NSOperationQueue.mainQueue()
    )
    private var sessionDelegate: SessionDelegate { return session.delegate as! SessionDelegate }
    
    let cacheTime: NSTimeInterval
    init(cacheTime: NSTimeInterval) {
        self.cacheTime = cacheTime
    }
    
    func cancelSession() {
        session.invalidateAndCancel()
        session = nil
    }
    
    
    func loadResource<R: Resource, Object where R.ParsedObject == Object>(resource: R, completion: SynchronizerResult<Object> -> ()) {
        
        func completeOnMainThread(result: SynchronizerResult<Object>) {
            if case .Error = result { print(result) }
            addToMainQueue{ completion(result) }
        }
        
        let request = resource.request()
        let task = session.dataTaskWithRequest(request)
        print("Request: \(request)")
        sessionDelegate.setCompletionHandlerForTask(task) { (data, response, error) in
            
            guard error?.code != NSURLErrorCancelled else {
                print("Request with URL: \(request.URL ?? "") was cancelled")
                return // cancel quitely
            }

            print("Response: \(response)")
            if let result = SynchronizerResult<Object>.resultWithResponse(response, error: error) {
                completeOnMainThread(result)
                return
            }
            
            guard let data = data where data.length > 0 else {
                completeOnMainThread(.NoData)
                return
            }

            do {
                let object = try resource.parse(data)
                completeOnMainThread(.Success(object))
            } catch {
                completeOnMainThread(.Error(error))
            }
        }
        task.resume()
    }
}

private extension SynchronizerResult {
    
    static func resultWithResponse(response: NSURLResponse?, error: NSError?) -> SynchronizerResult? {
        guard error == nil else {
            return Error(SynchronizerError.URLSessionError(error!))
        }
        let statusCode = (response as! NSHTTPURLResponse).statusCode
        guard 200..<300 ~= statusCode else {
            return Error(SynchronizerError.WrongStatusError(status: statusCode))
        }
        return nil
    }    
}
