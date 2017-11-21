//
//  LooponDate.swift
//  LooponKit
//
//  Created by Bruno Resende on 21/11/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
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
		/// Date only. Example: 2017-11-19
		case dateOnly

		/// Date and Time. Example: 2017-11-20T01:42:41Z
		case dateWithTime

		/// Date and Fractional Time. Example: 2017-11-21T17:50:48.813225Z
		case dateWithFractionalTime
	}

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

