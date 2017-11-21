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

	/// The actual date represented by this object.
	let date: Date

	/// Initializes with the current time and date.
	public init()
	{
		self.date = Date()
	}

	/// Initializes with the given date value.
	public init(date: Date)
	{
		self.date = date
	}

	/// Initializes with the given ISO8601-formatted string.
	public init?(isoString: String)
	{
		guard let date = LooponDate.isoDateFormatter.date(from: isoString) else
		{
			return nil
		}

		self.date = date
	}

	/// Initializes looking for an ISO8601-formatted string in the encoder as a single-value container (no keys).
	public init(from decoder: Decoder) throws
	{
		let container = try decoder.singleValueContainer()
		let isoString = try container.decode(String.self)

		guard
			let date = LooponDate.isoDateFormatter.date(from: isoString)
			else
		{
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "String is not ISO8601 formatted.")
		}

		self.date = date
	}

	/// Encodes the contained Date object into the encoder as a single-value container using the ISO8601 format.
	public func encode(to encoder: Encoder) throws
	{
		var container = encoder.singleValueContainer()
		try container.encode(LooponDate.isoDateFormatter.string(from: self.date))
	}
}

/// Type that wraps a Date with Time object with encoding/decoding routines compatible with Loopon's API.
public struct LooponDateWithTime: Codable
{
	public static var isoDateWithTimeFormatter: DateFormatter =
	{
		let formatter = DateFormatter()
		// See: http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
		formatter.timeZone = TimeZone(identifier: "Zulu")
		return formatter
	}()

	/// The actual date represented by this object.
	let date: Date

	/// Initializes with the current time and date.
	public init()
	{
		self.date = Date()
	}

	/// Initializes with the given date value.
	public init(date: Date)
	{
		self.date = date
	}

	/// Initializes with the given ISO8601-formatted string.
	public init?(isoString: String)
	{
		guard let date = LooponDateWithTime.isoDateWithTimeFormatter.date(from: isoString) else
		{
			return nil
		}

		self.date = date
	}

	/// Initializes looking for an ISO8601-formatted string in the encoder as a single-value container (no keys).
	public init(from decoder: Decoder) throws
	{
		let container = try decoder.singleValueContainer()
		let isoString = try container.decode(String.self)

		guard
			let date = LooponDateWithTime.isoDateWithTimeFormatter.date(from: isoString)
			else
		{
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "String is not ISO8601 formatted.")
		}

		self.date = date
	}

	/// Encodes the contained Date object into the encoder as a single-value container using the ISO8601 format.
	public func encode(to encoder: Encoder) throws
	{
		var container = encoder.singleValueContainer()
		try container.encode(LooponDateWithTime.isoDateWithTimeFormatter.string(from: self.date))
	}
}
