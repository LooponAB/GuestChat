//
//  LooponGuestStay.swift
//  LooponKit
//
//  Created by Bruno Resende on 20/11/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import Foundation

/// Representation of a guest’s specific stay at a specific hotel.
public class LooponGuestStay: Decodable
{
	/// Unique id identifying this specific stay.
	public let stayId: Int

	/// Unique identifier of the hotel for which this is a stay.
	public let unitId: Int

	/// The current status of the guest in their journey.
	public let status: Status

	/// Booking reference as provided by the PMS.
	public let bookingReference: String?

	/// Date when stay was booked given in ISO 8601 format.
	public let bookingDate: LooponDate?

	/// Arrival date.
	public let checkinDate: LooponDate?

	/// Departure date.
	public let checkoutDate: LooponDate?

	/// Guest's room number.
	public let room: String?

	/// ISO 639-1 representation of the language the guest prefers to speak. This is a per-stay option.
	public let language: String

	/// The guest associated with this stay. Can be null for anonymous/un-identified stays.
	public let guest: LooponGuest?

	/// Chat Session associated with this stay.
	public let chatSession: LooponChatSession

	public enum Status: String, Codable
	{
		/// Guest has not arrived yet.
		case prestay

		/// Guest is currently at the hotel.
		case instay

		/// Guest has checked out from hotel.
		case poststay

		/// Guest is currently booking a new stay.
		case nextstay
	}
}
