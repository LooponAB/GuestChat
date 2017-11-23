//
//  DecodableFetcher.swift
//  GuestChat
//
//  Created by Bruno Resende on 20/11/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import Foundation

class DecodableFetcher
{
	internal func fetchDecodable<T: Decodable>(with request: URLRequest, _ callback: @escaping (Response<T>) -> Void)
	{
		let task = URLSession.shared.dataTask(with: request)
		{
			(data, response, error) in

			if let error = error
			{
				callback(.error(error, data))
				return
			}
			else if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode != 200
			{
				callback(.error(FetcherError.badStatus(statusCode), data))
				return
			}

			guard let safeData = data, safeData.count > 0 else
			{
				callback(.error(FetcherError.emptyResponse, data))
				return
			}

			do
			{
				callback(.success(try JSONDecoder().decode(T.self, from: safeData)))
			}
			catch
			{
				callback(.error(error, safeData))
			}
		}

		task.resume()
	}

	enum FetcherError: Error
	{
		case badStatus(Int)
		case emptyResponse
	}

	enum Response<T>
	{
		case error(Error, Data?)
		case success(T)
	}
}

protocol StringParameter
{
	var parameterValue: String { get }
}

extension Dictionary where Key == String, Value == StringParameter
{
	var asString: String
	{
		return map({ (key, value) -> String in "\(key)=\(value)" }).joined(separator: "&")
	}

	var asData: Data?
	{
		return asString.data(using: .utf8)
	}
}

extension String: StringParameter
{
	var parameterValue: String
	{
		return self
	}
}

extension Int: StringParameter
{
	var parameterValue: String
	{
		return "\(self)"
	}
}
