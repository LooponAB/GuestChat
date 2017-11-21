//
//  LooponUnit.swift
//  LooponKit
//
//  Created by Bruno Resende on 20/11/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import Foundation

/// Description of a single hotel/restaurant/cruise ship.
public class LooponUnit: Codable
{
	/// Unique identifier for this unit.
	public let unitId: Int

	/// Property code of this unit, as identified by the chain of which it is a member.
	///
	/// *Note:* This value is usually picked by the hotel chain.
	public let propertyCode: String?

	/// Human readable name of this unit.
	public let name: String
}
