//
//  LooponGuestStay.swift
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
