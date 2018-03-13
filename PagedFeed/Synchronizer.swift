//
//  Synchronizer.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 31/05/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

protocol Resource {
    func request() -> URLRequest
    
    associatedtype ParsedObject
    var parse: (Data) throws -> ParsedObject { get }
}

enum SynchronizerResult<Result> {
    case success(Result)
    case noData
    case error(Error) /// Might be SynchronizerError or parsing error thrown by Resource parse function
}

enum SynchronizerError: Error {
    case wrongStatusError(status: Int)
    case urlSessionError(NSError)
}


class Synchronizer {
    
    fileprivate lazy var session = self.createSession()
    private func createSession() -> URLSession {
        return URLSession(
            configuration: self.sessionConfiguration,
            delegate: SessionDelegate(cacheTime: self.cacheTime),
            delegateQueue: OperationQueue.main
        )
    }
    fileprivate var sessionDelegate: SessionDelegate { return session.delegate as! SessionDelegate }
    fileprivate let sessionConfiguration: URLSessionConfiguration
    fileprivate let cacheTime: TimeInterval
    
    init(cacheTime: TimeInterval, URLCache: Foundation.URLCache? = URLSessionConfiguration.default.urlCache) {
        self.cacheTime = cacheTime
        self.sessionConfiguration = URLSessionConfiguration.default
        self.sessionConfiguration.urlCache = URLCache
    }
    
    func cancelSession() {
        session.invalidateAndCancel()
        session = createSession()
    }
    
    typealias CancelLoading = () -> Void
    
    func loadResource<R: Resource, Object>
        (_ resource: R, completion: @escaping (SynchronizerResult<Object>) -> ()) -> CancelLoading where R.ParsedObject == Object {
        
        func completeOnMainThread(_ result: SynchronizerResult<Object>) {
            if case .error = result { print(result) }
            OperationQueue.main.addOperation{ completion(result) }
        }
        
        let request = resource.request()
        let task = session.dataTask(with: request)
        print("Request: \(request)")
        sessionDelegate.setCompletionHandlerForTask(task) { (data, response, error) in
            
            guard error?.code != NSURLErrorCancelled else {
                print("Request with URL: \(request.url ?? nil) was cancelled")
                return // cancel quitely
            }

            print("Response: \(response)")
            if let result = SynchronizerResult<Object>.resultWithResponse(response, error: error) {
                completeOnMainThread(result)
                return
            }
            
            guard let data = data, data.count > 0 else {
                completeOnMainThread(.noData)
                return
            }

            do {
                let object = try resource.parse(data)
                completeOnMainThread(.success(object))
            } catch {
                completeOnMainThread(.error(error))
            }
        }
        task.resume()
        
        return { [weak task] in
            task?.cancel()
        }
    }
}

private extension SynchronizerResult {
    
    static func resultWithResponse(_ response: URLResponse?, error: NSError?) -> SynchronizerResult? {
        guard error == nil else {
            return self.error(SynchronizerError.urlSessionError(error!))
        }
        let statusCode = (response as! HTTPURLResponse).statusCode
        guard 200..<300 ~= statusCode else {
            return self.error(SynchronizerError.wrongStatusError(status: statusCode))
        }
        return nil
    }    
}
