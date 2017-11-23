//
//  UnitPickerViewController.swift
//  GuestChat
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

import UIKit
import LooponKit

class UnitPickerViewController: UITableViewController
{
	var units: [LooponUnit]? = nil

    override func viewDidLoad()
	{
        super.viewDidLoad()

        units = AppDelegate.instance.units
    }

	var selectionCallback: ((LooponUnit) -> Void)? = nil

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
	{
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
        return units?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_unit", for: indexPath)

        // Configure the cell...
		if let unit = units?[indexPath.row]
		{
			cell.textLabel?.text = unit.name
			cell.detailTextLabel?.text = unit.propertyCode
		}

        return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		guard let callback = selectionCallback, let unit = units?[indexPath.row] else
		{
			return
		}

		callback(unit)

		navigationController?.popViewController(animated: true)
	}
}
