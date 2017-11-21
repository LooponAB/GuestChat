//
//  Secrets.swift
//  GuestChat
//
//  Created by Bruno Resende on 23/11/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import Foundation

// >>> Important! <<<
//
// Duplicate this file in your project and name it "Secrets.swift".
// Xcode is expecting this file to exist, but "Secrets.swift" is in the .gitignore, to prevent
// your secrets from being added to git.
struct SecretsExample // << Rename this to Secrets
{
	static let clientId: String		= "YOUR_CLIENT_ID"
	static let clientSecret: String	= "YOUR_CLIENT_SECRET"
}
