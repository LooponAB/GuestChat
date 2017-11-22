//
//  String+Hash.swift
//  LooponKit
//
//  Created by Bruno Resende on 17/11/2017.
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
import CommonCrypto

extension String
{
	/// SHA-256 hash of the receiver string.
	var sha256Hash: String
	{
		let str = cString(using: .utf8)
		let strLen = CC_LONG(lengthOfBytes(using: .utf8))
		let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
		let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)

		CC_SHA256(str!, strLen, result)

		let hash = NSMutableString()
		for i in 0..<digestLen
		{
			hash.appendFormat("%02x", result[i])
		}

		result.deallocate(capacity: digestLen)

		return String(format: hash as String)
	}

	/// The base64 representation of the receiver string when serialized using UTF-8.
	var base64Encoded: String
	{
		let utf8Data = data(using: .utf8)
		return utf8Data!.base64EncodedString(options: [])
	}
}
