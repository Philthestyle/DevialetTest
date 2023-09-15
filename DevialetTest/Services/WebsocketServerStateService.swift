//
//  WebsocketServerStateService.swift
//  DevialetTest
//
//  Created by Faustin on 15/09/2023.
//

import Foundation

protocol WebsocketServerStateServiceProtocol {
    func checkServerRunningState(urlPath: String, completion: @escaping (_ isValid: Bool) ->())
}

struct WebsocketServerStateService: WebsocketServerStateServiceProtocol {
    static let shared = WebsocketServerStateService()
    
    /*
     check if baseurl from webSocket is working
        -> indicates if server is running, else, server is not running or baseURL is wrong
     */
    func checkServerRunningState(urlPath: String, completion: @escaping (_ isValid: Bool) ->()) {
        if let url = URL(string: urlPath) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        completion(true)
                    }
                } else {
                    completion(false)
                }
            }
            task.resume()
        } else {
            completion(false)
        }
    }
}
