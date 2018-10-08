//
//  HTTPResponse.swift
//  Telegraph
//
//  Created by Yvo van Beek on 1/31/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

open class HTTPResponse: HTTPMessage {
  public typealias Handler = (HTTPResponse, Error) -> Void

  public var status: HTTPStatus
  public var closeAfterWrite = false

  /// Initializes a new HTTPResponse
  public init(_ status: HTTPStatus = .ok, version: HTTPVersion = HTTPVersion(1, 1),
              headers: HTTPHeaders = .empty, body: Data = Data()) {
    self.status = status
    super.init(version: version, headers: headers, body: body)
  }

  /// Writes the first line of the response, e.g. HTTP/1.1 200 OK
  override internal var firstLine: String {
    return "\(version) \(status)"
  }

  /// Prepares the response to be written tot the stream
  override open func prepareForWrite() {
    super.prepareForWrite()

    // Set the date header
    headers.date = Date().rfc1123

    // If a body is allowed set the content length (even when 0)
    if status.supportsBody {
      headers.contentLength = body.count
    } else {
      headers.contentLength = nil
      body.count = 0
    }
  }
}

// MARK: Convenience initializers

extension HTTPResponse {
  /// Creates an HTTP response to send textual content.
  public convenience init(_ status: HTTPStatus = .ok, headers: HTTPHeaders = .empty, content: String) {
    self.init(status, headers: headers, body: content.utf8Data)
  }

  /// Creates an HTTP response to send an error.
  public convenience init(_ status: HTTPStatus = .internalServerError, headers: HTTPHeaders = .empty, error: Error) {
    self.init(status, headers: headers, body: error.localizedDescription.utf8Data)
  }
}

// MARK: CustomStringConvertible

extension HTTPResponse: CustomStringConvertible {
  open var description: String {
    let typeName = type(of: self)
    return "<\(typeName): \(version) \(status), headers: \(headers.count), body: \(body.count)>"
  }
}

// MARK: Deprecated

extension HTTPResponse {
  @available(*, deprecated, message: "use DateFormatter.rfc1123 or Date's rfc1123 variable")
  public static let dateFormatter = DateFormatter.rfc1123

  @available(*, deprecated, message: "data: has been renamed to body:")
  public convenience init(_ status: HTTPStatus = .ok, data: Data) {
    self.init(status, body: data)
  }
}
