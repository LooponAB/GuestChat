//
//  LooponDate.swift
//  LooponKit
//
//  Created by Bruno Resende on 21/11/2017.
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

/// Type that wraps a Date object with encoding/decoding routines compatible with Loopon's API.
public struct LooponDate: Codable
{
	public static var isoDateFormatter: DateFormatter =
	{
		let formatter = DateFormatter()
		// See: http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter
	}()

	public static var isoDateWithTimeFormatter: DateFormatter =
	{
		let formatter = DateFormatter()
		// See: http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
		return formatter
	}()

	public static var isoDateWithFractionalTimeFormatter: DateFormatter =
	{
		let formatter = DateFormatter()
		// See: http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
		return formatter
	}()

	/// The actual date represented by this object.
	public let date: Date

	/// The mode used to decode, or that should be used to encode, this date.
	public let formatMode: Mode

	/// Initializes with the current time and date.
	public init(formatMode: Mode = .dateOnly)
	{
		self.date = Date()
		self.formatMode = formatMode
	}

	/// Initializes with the given date value.
	public init(date: Date, formatMode: Mode = .dateOnly)
	{
		self.date = date
		self.formatMode = formatMode
	}

	/// Initializes with the given ISO8601-formatted string.
	public init?(isoString: String)
	{
		guard let (mode, date) = LooponDate.tryDecode(isoString) else
		{
			return nil
		}

		self.date = date
		self.formatMode = mode
	}

	/// Initializes looking for an ISO8601-formatted string in the encoder as a single-value container (no keys).
	public init(from decoder: Decoder) throws
	{
		let container = try decoder.singleValueContainer()
		let isoString = try container.decode(String.self)

		guard let (mode, date) = LooponDate.tryDecode(isoString) else
		{
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "String is not ISO8601 formatted: \(isoString)")
		}

		self.date = date
		self.formatMode = mode
	}

	/// Encodes the contained Date object into the encoder as a single-value container using the ISO8601 format.
	public func encode(to encoder: Encoder) throws
	{
		var container = encoder.singleValueContainer()
		try container.encode(LooponDate.isoDateFormatter.string(from: self.date))
	}

	public enum Mode
	{
		/// Date only.
		/// Example: 2017-11-19
		case dateOnly

		/// Date and Time.
		/// Example: 2017-11-20T01:42:41Z
		case dateWithTime

		/// Date and Fractional Time.
		/// Example: 2017-11-21T17:50:48.813225Z
		case dateWithFractionalTime
	}

	/// Attempts to decode the date string using all supported formats. If successful, returns a tuple with the format
	/// that was detected, and the date object. Otherwise returns nil.
	private static func tryDecode(_ string: String) -> (Mode, Date)?
	{
		let modes: [Mode: DateFormatter] = [
			.dateOnly: LooponDate.isoDateFormatter,
			.dateWithTime: LooponDate.isoDateWithTimeFormatter,
			.dateWithFractionalTime: LooponDate.isoDateWithFractionalTimeFormatter
		]

		for (mode, formatter) in modes
		{
			if let dateForMode = formatter.date(from: string)
			{
				return (mode, dateForMode)
			}
		}

		return nil
	}
}

