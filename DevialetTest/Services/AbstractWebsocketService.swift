//
//  AbstractWebsocketService.swift
//  DevialetTest
//
//  Created by Faustin on 15/09/2023.
//  Source: https://www.donnywals.com/iterating-over-web-socket-messages-with-async-await-in-swift/


import Foundation

/*
 After having some articles about Websocket in swift, I had some issues with websocket session concurrency
 Then I have found this article: https://www.donnywals.com/iterating-over-web-socket-messages-with-async-await-in-swift/
 speaking about the best way to treat concurrency manipulatin websockets natively in swift
 */
typealias WebSocketStream = AsyncThrowingStream<URLSessionWebSocketTask.Message, Error>

public extension URLSessionWebSocketTask {
    internal var stream: WebSocketStream {
        return WebSocketStream { continuation in
            Task {
                var isAlive = true

                while isAlive && closeCode == .invalid {
                    do {
                        let value = try await receive()
                        continuation.yield(value)
                    } catch {
                        continuation.finish(throwing: error)
                        isAlive = false
                    }
                }
            }
        }
    }
}

class AbstractWebsocketService: AsyncSequence {
    typealias AsyncIterator = WebSocketStream.Iterator
    typealias Element = URLSessionWebSocketTask.Message

    private var continuation: WebSocketStream.Continuation?
    private let task: URLSessionWebSocketTask

    private lazy var stream: WebSocketStream = {
        return WebSocketStream { continuation in
            self.continuation = continuation

            Task {
                var isAlive = true

                while isAlive && task.closeCode == .invalid {
                    do {
                        let value = try await task.receive()
                        continuation.yield(value)
                    } catch {
                        continuation.finish(throwing: error)
                        isAlive = false
                    }
                }
            }
        }
    }()

    init(task: URLSessionWebSocketTask) {
        self.task = task
        task.resume()
    }

    deinit {
        continuation?.finish()
    }

    func makeAsyncIterator() -> AsyncIterator {
        return stream.makeAsyncIterator()
    }

    func cancel() async throws {
        task.cancel(with: .goingAway, reason: nil)
        continuation?.finish()
    }
}
