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
    
    let cacheTime: NSTimeInterval
    
    init(cacheTime: NSTimeInterval) {
        self.cacheTime = cacheTime
    }
    
    typealias TaskCompletionHandler = (NSData?, NSURLResponse?, NSError?) -> Void

    func setCompletionHandlerForTask(task: NSURLSessionDataTask, handler: TaskCompletionHandler) {
        completionHandlerForTask[task] = handler
    }
    
    private var completionHandlerForTask = [NSURLSessionTask: TaskCompletionHandler]()
    private var dataForTask = [NSURLSessionTask: NSMutableData?]()
}

extension SessionDelegate: NSURLSessionTaskDelegate {
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        let data = dataForTask[task] ?? nil
        completionHandlerForTask[task]?(data, task.response, error)
        completionHandlerForTask[task] = nil
    }
}

extension SessionDelegate: NSURLSessionDataDelegate {
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        guard let mutableData = dataForTask[dataTask] else {
            dataForTask[dataTask] = NSMutableData(data: data)
            return
        }
        mutableData?.appendData(data)
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, willCacheResponse proposedResponse: NSCachedURLResponse, completionHandler: (NSCachedURLResponse?) -> Void) {
        switch proposedResponse.response {
        case let response as NSHTTPURLResponse:
            var headers = response.allHeaderFields as! [String: String]
            headers["Cache-Control"] = "max-age=\(cacheTime)"
            
            let modifiedResponse = NSHTTPURLResponse(URL: response.URL!,
                                                     statusCode: response.statusCode,
                                                     HTTPVersion: "HTTP/1.1",
                                                     headerFields: headers)
            let modifiedCachedResponse = NSCachedURLResponse(response: modifiedResponse!,
                                                             data: proposedResponse.data,
                                                             userInfo: proposedResponse.userInfo,
                                                             storagePolicy: proposedResponse.storagePolicy)
            completionHandler(modifiedCachedResponse)
        default:
            completionHandler(proposedResponse)
        }
    }
}
