//
//  DecodableFetcher.swift
//  GuestChat
//
//  Created by Bruno Resende on 20/11/2017.
//  Copyright © 2017 Loopon AB
//  API Documentation: https://api.loopon.com/public
//  Contact us at support@loopon.com
//  
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 
//  following conditions are met:
//  
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following
//  disclaimer.
//  
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the 
//  following disclaimer in the documentation and/or other materials provided with the distribution.
//  
//  3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote
//  products derived from this software without specific prior written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
//  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
//  USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
