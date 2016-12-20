//
//  SessionDelegate.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 04/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

/**
 The only benefit SessionDelegate provides is to accompany URL respones with cache control headers which are not provided by the backend at the time of writing.
 (Cache control headers in responses let us use Foundation's NSURLCache abilities.)
 
 Once the backend implementation is changed to provide responses with cache control headers SessionDelegate should no longer be used.
 
 NOT THREAD SAFE - it should be used on the delegation queue of NSURLSession
 */
class SessionDelegate: NSObject {
    
    let cacheTime: TimeInterval
    
    init(cacheTime: TimeInterval) {
        self.cacheTime = cacheTime
    }
    
    typealias TaskCompletionHandler = (Data?, URLResponse?, NSError?) -> Void

    func setCompletionHandlerForTask(_ task: URLSessionDataTask, handler: @escaping TaskCompletionHandler) {
        completionHandlerForTask[task] = handler
    }
    
    fileprivate var completionHandlerForTask = [URLSessionTask: TaskCompletionHandler]()
    fileprivate var dataForTask = [URLSessionTask: NSMutableData?]()
}

extension SessionDelegate: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let data = dataForTask[task] ?? nil
        completionHandlerForTask[task]?(data as Data?, task.response, error as NSError?)
        completionHandlerForTask[task] = nil
    }
}

extension SessionDelegate: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let mutableData = dataForTask[dataTask] else {
            dataForTask[dataTask] = NSData(data: data) as Data as Data
            return
        }
        mutableData?.append(data)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        switch proposedResponse.response {
        case let response as HTTPURLResponse:
            var headers = response.allHeaderFields as! [String: String]
            headers["Cache-Control"] = "max-age=\(cacheTime)"
            
            let modifiedResponse = HTTPURLResponse(url: response.url!,
                                                     statusCode: response.statusCode,
                                                     httpVersion: "HTTP/1.1",
                                                     headerFields: headers)
            let modifiedCachedResponse = CachedURLResponse(response: modifiedResponse!,
                                                             data: proposedResponse.data,
                                                             userInfo: proposedResponse.userInfo,
                                                             storagePolicy: proposedResponse.storagePolicy)
            completionHandler(modifiedCachedResponse)
        default:
            completionHandler(proposedResponse)
        }
    }
}
