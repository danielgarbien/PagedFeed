//
//  Synchronizer.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 31/05/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

protocol Resource {
    func request() -> NSURLRequest
    
    associatedtype ParsedObject
    var parse: (NSData) throws -> ParsedObject { get }
}

enum SynchronizerResult<Result> {
    case Success(Result)
    case NoData
    case Error(ErrorType) /// Might be SynchronizerError or parsing error thrown by Resource parse function
}

enum SynchronizerError: ErrorType {
    case WrongStatusError(status: Int)
    case URLSessionError(NSError)
}


class Synchronizer {
    
    private lazy var session: NSURLSession! = NSURLSession(
        configuration: self.sessionConfiguration,
        delegate: SessionDelegate(cacheTime: self.cacheTime),
        delegateQueue: NSOperationQueue.mainQueue()
    )
    private var sessionDelegate: SessionDelegate { return session.delegate as! SessionDelegate }
    private let sessionConfiguration: NSURLSessionConfiguration
    private let cacheTime: NSTimeInterval
    
    init(cacheTime: NSTimeInterval, URLCache: NSURLCache? = NSURLSessionConfiguration.defaultSessionConfiguration().URLCache) {
        self.cacheTime = cacheTime
        self.sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.sessionConfiguration.URLCache = URLCache
    }
    
    func cancelSession() {
        session.invalidateAndCancel()
        session = nil
    }
    
    typealias CancelLoading = () -> Void
    
    func loadResource<R: Resource, Object where R.ParsedObject == Object>
        (resource: R, completion: SynchronizerResult<Object> -> ()) -> CancelLoading {
        
        func completeOnMainThread(result: SynchronizerResult<Object>) {
            if case .Error = result { print(result) }
            NSOperationQueue.mainQueue().addOperationWithBlock{ completion(result) }
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
        
        return { [weak task] in
            task?.cancel()
        }
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
