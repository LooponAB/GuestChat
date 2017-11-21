//
//  LooponAuthorization.swift
//  LooponKit
//
//  Created by Bruno Resende on 20/11/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import Foundation

public struct LooponAuthorization: Codable
{
	private let created = Date()

	/// The token type. Usually "Bearer".
	public let tokenType: String

	/// The expiration delta time after creation.
	public let expiresIn: TimeInterval

	/// The access token.
	public let accessToken: String

	/// The exact date when the authorization expires.
	public var expiration: Date
	{
		return created.addingTimeInterval(expiresIn)
	}

	enum CodingKeys: String, CodingKey
	{
		case tokenType = "token_type"
		case expiresIn = "expires_in"
		case accessToken = "access_token"
	}

	public var httpHeaderValue: String
	{
		return "\(tokenType) \(accessToken)"
	}
}
