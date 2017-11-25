//
//  Router.swift
//  BlockathonDemo
//
//  Created by Vanalite on 11/24/17.
//  Copyright © 2017 Vanalite. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

public enum HTTPMethod: String {
  case POST = "POST"
  case GET = "GET"
  case PUT = "PUT"
  case DELETE = "DELETE"
}

class Router {
  // User paths
  private static let loginPath = "users/login"
  private static let userPath = "users"
  // Balance paths
	private static let balancePath = "utils/checkBalance"
	// History paths
	private static let historyPath = "bidHistories"
  private static let contentTypeHeaderField = "Content-Type"
  private static let applicationJSONContentType = "application/json"
  static let multipartFormDataContentType = "multipart/form-data"

  // MARK: User requests
  class func signInRequest(param: JSONParams) -> URLRequestConvertible {
    return createUrlRequestWithRelativePath(relativePath: loginPath, params: param, httpMethod: .POST)
  }

  class func fetchUser(param: JSONParams? = nil) -> URLRequestConvertible {
    let path = userPath
    return createUrlRequestWithRelativePath(relativePath: path, params: param, httpMethod: .GET)
  }

	class func requestBalance(param: JSONParams) -> URLRequestConvertible {
		return createUrlRequestWithRelativePath(relativePath: balancePath, params: param, httpMethod: .GET)
	}

	class func fetchHistory(param: JSONParams? = nil) -> URLRequestConvertible {
		let path = historyPath
		return createUrlRequestWithRelativePath(relativePath: path, params: param, httpMethod: .GET)
	}

  // MARK: Private methods
  private class func createUrlRequestWithRelativePath(relativePath: String, params: JSONParams?, httpMethod: HTTPMethod, contentType: String? = applicationJSONContentType) -> URLRequestConvertible {
    let baseUrl = NSURL(string: Constants.baseApiUrl)!
		var request = URLRequest(url:  baseUrl.appendingPathComponent(relativePath)!)
    request.httpMethod = httpMethod.rawValue
    request.setValue(Constants.apiAppToken, forHTTPHeaderField: "access_token")
		if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
			let accessTokenParameters: Parameters = ["access_token": accessToken]
			request = try! URLEncoding.queryString.encode(request, with: accessTokenParameters)
		}
    if let contentType = contentType {
      request.setValue(contentType, forHTTPHeaderField: contentTypeHeaderField)
    }
		if httpMethod == HTTPMethod.GET {
			let encodedURLRequest = try! URLEncoding.queryString.encode(request, with: params?.toParam())
			return encodedURLRequest;
		}
		let encodedURLRequest = try! JSONEncoding.default.encode(request, with: params?.toParam())
		return encodedURLRequest;
  }
}