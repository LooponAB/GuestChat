//
//  HotelBackend.swift
//  GuestChat
//
//  Created by Bruno Resende on 20/11/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import Foundation
import LooponKit

protocol HotelBackendDelegate: class
{
	func hotelBackedDidAuthorize(_ hotelBackend: HotelBackend)
}

class HotelBackend: DecodableFetcher
{
	static private let looponBaseUrl = "https://api.loopon.com/"

	private let clientId: String
	private let clientSecret: String

	private var authorization: LooponAuthorization? = nil
	{
		didSet
		{
			self.delegate?.hotelBackedDidAuthorize(self)
		}
	}

	weak var delegate: HotelBackendDelegate? = nil
	{
		didSet
		{
			self.delegate?.hotelBackedDidAuthorize(self)
		}
	}

	init(clientId: String, secret: String)
	{
		self.clientId = clientId
		self.clientSecret = secret

		super.init()

		authorize
			{
				[weak self] response in

				switch response
				{
				case .success(let authorization):
					self?.authorization = authorization

				case .error(let error, let data):
					print("Error! Could not authorize! \(error)")

					if let data = data
					{
						print("Data: \(String(data: data, encoding: .utf8) ?? "nil data")")
					}
				}
			}
	}

	func getUnits(callback: @escaping (Response<[LooponUnit]>) -> Void) throws
	{
		fetchDecodable(with: try makeRequest(path: "public/units"), callback)
	}

	func getUnits(with propertyCode: String, callback: @escaping (Response<[LooponUnit]>) -> Void) throws
	{
		fetchDecodable(with: try makeRequest(path: "public/units", urlParameters: ["propertyCode": propertyCode]), callback)
	}

	func getUnits(with unitId: Int, callback: @escaping (Response<LooponUnit>) -> Void) throws
	{
		fetchDecodable(with: try makeRequest(path: "public/unit/\(unitId)"), callback)
	}

	func postStay(guestData: StayPayload, callback: @escaping (Response<LooponGuestStay>) -> Void) throws
	{
		let bodyData = try JSONEncoder().encode(guestData)

		fetchDecodable(with: try makeRequest(path: "public/units/\(guestData.unitId)/stays", method: .post(bodyData)), callback)
	}

	struct StayPayload: Encodable
	{
		let unitId: Int
		let name: String
		let room: String
		let bookingReference: String
		let email: String
		let mobile: String
		let language: String
		let bookingDate: LooponDate
		let checkinDate: LooponDate
		let checkoutDate: LooponDate
		let status: JourneyStage

		enum JourneyStage: Int, Encodable
		{
			case preStay = 0
			case inStay = 1
			case postStay = 2

			func encode(to encoder: Encoder) throws
			{
				var container = encoder.singleValueContainer()
				try container.encode(stringValue)
			}

			var stringValue: String
			{
				switch self
				{
				case .preStay:	return "prestay"
				case .inStay:	return "instay"
				case .postStay:	return "poststay"
				}
			}
		}
	}

	enum HotelError: Error
	{
		case noAuthorization
		case badPayload
	}

	// MARK: Private methods

	private enum Method
	{
		case get
		case post(Data)

		var httpMethod: String
		{
			switch self
			{
			case .get:		return "GET"
			case .post:		return "POST"
			}
		}

		var httpBody: Data?
		{
			switch self
			{
			case .get:					return nil
			case .post(let data):		return data
			}
		}
	}

	private func makeRequest(path: String, urlParameters: [String: StringParameter]? = nil, method: Method = .get) throws -> URLRequest
	{
		guard let auth = self.authorization else
		{
			throw HotelError.noAuthorization
		}

		let query = urlParameters == nil ? "" : "?\(urlParameters!.asString)"

		if let data = method.httpBody
		{
			print("Sending body: \(String(data: data, encoding: .utf8) ?? data.description)")
		}

		var request = URLRequest(url: URL(string: "\(HotelBackend.looponBaseUrl)\(path)\(query)")!)
		request.httpMethod = method.httpMethod
		request.httpBody = method.httpBody
		request.setValue("1", forHTTPHeaderField: "VERSION")
		request.setValue(auth.httpHeaderValue, forHTTPHeaderField: "Authorization")
		return request
	}

	private func authorize(_ callback: @escaping (Response<LooponAuthorization>) -> Void)
	{
		let bodyParameters: [String: StringParameter] = [
			"grant_type": "client_credentials",
			"client_id": clientId,
			"client_secret": clientSecret,
			"scope": "basic manage_stays chat_sessions"
		]

		var authorizationRequest = URLRequest(url: URL(string: "\(HotelBackend.looponBaseUrl)oauth2/token")!)
		authorizationRequest.httpBody = bodyParameters.asData
		authorizationRequest.httpMethod = "POST"

		fetchDecodable(with: authorizationRequest, callback)
	}
}
