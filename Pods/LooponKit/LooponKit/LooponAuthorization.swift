//
//  LooponAuthorization.swift
//  LooponKit
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

/// Represents an Oauth2 authorization object.
public struct LooponAuthorization: Codable
{
	/// Date when this object was created. Used in conjunction with `expiresIn` to calculate the expiration date.
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

	/// A HTTP Header value based on the contents of this authorization.
	public var httpHeaderValue: String
	{
		return "\(tokenType) \(accessToken)"
	}
}
