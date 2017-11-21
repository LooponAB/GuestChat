//
//  UnitPickerViewController.swift
//  GuestChat
//
//  Created by Bruno Resende on 20/11/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
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
