//
//  SetupDemoViewController.swift
//  GuestChat
//
//  Created by Bruno Resende on 17/11/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import UIKit

class SetupDemoViewController: UITableViewController
{
	@IBOutlet weak var textFieldGuestName: UITextField!
	@IBOutlet weak var textFieldRoomNumber: UITextField!
	@IBOutlet weak var textFieldBookingReference: UITextField!
	@IBOutlet weak var textFieldEmail: UITextField!
	@IBOutlet weak var textFieldPhone: UITextField!
	@IBOutlet weak var textFieldCheckinDate: UITextField!
	@IBOutlet weak var textFieldCheckoutDate: UITextField!
	@IBOutlet weak var segmentedControlJourneyStage: UISegmentedControl!

	var doneCallback: ((DemoData) -> Void)? = nil

	var demoData: DemoData?
	{
		guard
			let checkinDate = textFieldCheckinDate.dateValue,
			let checkoutDate = textFieldCheckoutDate.dateValue,
			let journeyStage = segmentedControlJourneyStage.guestJourneyValue
		else
		{
			return nil
		}

		return DemoData(guestName: textFieldGuestName.stringValue,
						roomNumber: textFieldRoomNumber.stringValue,
						bookingRef: textFieldBookingReference.stringValue,
						email: textFieldEmail.stringValue,
						phone: textFieldPhone.stringValue,
						checkinDate: checkinDate,
						checkoutDate: checkoutDate,
						journeyStage: journeyStage)
	}

	private lazy var dateFormatter: DateFormatter =
		{
			let dateFormatter = DateFormatter()
			dateFormatter.timeStyle = .none
			dateFormatter.dateStyle = .medium
			return dateFormatter
		}()

	override func viewDidLoad()
	{
		super.viewDidLoad()

		let today = Date()
		let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today

		let checkinDatePicker = UIDatePicker()
		checkinDatePicker.minimumDate = today
		checkinDatePicker.setDate(today, animated: false)
		checkinDatePicker.datePickerMode = .date
		checkinDatePicker.addTarget(self, action: #selector(SetupDemoViewController.didChangeDatePicker(_:)), for: .valueChanged)
		textFieldCheckinDate.inputView = checkinDatePicker
		didChangeDatePicker(checkinDatePicker)

		let checkoutDatePicker = UIDatePicker()
		checkoutDatePicker.minimumDate = tomorrow
		checkoutDatePicker.setDate(tomorrow, animated: false)
		checkoutDatePicker.datePickerMode = .date
		checkoutDatePicker.addTarget(self, action: #selector(SetupDemoViewController.didChangeDatePicker(_:)), for: .valueChanged)
		textFieldCheckoutDate.inputView = checkoutDatePicker
		didChangeDatePicker(checkoutDatePicker)
	}

	@objc private func didChangeDatePicker(_ sender: UIDatePicker?)
	{
		if sender === textFieldCheckinDate.inputView, let date = sender?.date
		{
			textFieldCheckinDate.text = dateFormatter.string(from: date)
		}
		else if sender === textFieldCheckoutDate.inputView, let date = sender?.date
		{
			textFieldCheckoutDate.text = dateFormatter.string(from: date)
		}
	}

	@IBAction func done(_ sender: Any?)
	{
		if let demoData = self.demoData
		{
			doneCallback?(demoData)
			dismiss(animated: true, completion: nil)
		}
	}

	struct DemoData
	{
		let guestName: String
		let roomNumber: String
		let bookingRef: String
		let email: String
		let phone: String
		let checkinDate: Date
		let checkoutDate: Date
		let journeyStage: JourneyStage

		enum JourneyStage: Int
		{
			case preStay = 0
			case inStay = 1
			case postSTay = 2
		}
	}
}

extension UITextField
{
	var stringValue: String
	{
		return text ?? ""
	}

	var dateValue: Date?
	{
		return (inputView as? UIDatePicker)?.date
	}
}

extension UISegmentedControl
{
	var guestJourneyValue: SetupDemoViewController.DemoData.JourneyStage?
	{
		return SetupDemoViewController.DemoData.JourneyStage(rawValue: selectedSegmentIndex)
	}
}
