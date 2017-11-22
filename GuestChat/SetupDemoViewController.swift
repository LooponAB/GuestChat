//
//  SetupDemoViewController.swift
//  GuestChat
//
//  Created by Bruno Resende on 17/11/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import UIKit
import LooponKit

class SetupDemoViewController: UITableViewController
{
	private var pickedUnit: LooponUnit? = nil

	private lazy var dateFormatter: DateFormatter =
	{
		let dateFormatter = DateFormatter()
		dateFormatter.timeStyle = .none
		dateFormatter.dateStyle = .medium
		return dateFormatter
	}()

	@IBOutlet weak var labelUnitName: UILabel!
	@IBOutlet weak var textFieldGuestName: UITextField!
	@IBOutlet weak var textFieldRoomNumber: UITextField!
	@IBOutlet weak var textFieldBookingReference: UITextField!
	@IBOutlet weak var textFieldEmail: UITextField!
	@IBOutlet weak var textFieldPhone: UITextField!
	@IBOutlet weak var textFieldBookingDate: UITextField!
	@IBOutlet weak var textFieldCheckinDate: UITextField!
	@IBOutlet weak var textFieldCheckoutDate: UITextField!
	@IBOutlet weak var segmentedControlJourneyStage: UISegmentedControl!

	var doneCallback: ((HotelBackend.StayPayload) -> Void)? = nil
	var demoData: HotelBackend.StayPayload?
	{
		guard
			let unitId = pickedUnit?.unitId,
			let bookingDate = textFieldBookingDate.dateValue,
			let checkinDate = textFieldCheckinDate.dateValue,
			let checkoutDate = textFieldCheckoutDate.dateValue,
			let journeyStage = segmentedControlJourneyStage.guestJourneyValue
		else
		{
			return nil
		}

		return HotelBackend.StayPayload(unitId: unitId,
										name: textFieldGuestName.stringValue,
										room: textFieldRoomNumber.stringValue,
										bookingReference: textFieldBookingReference.stringValue,
										email: textFieldEmail.stringValue,
										mobile: textFieldPhone.stringValue,
										language: "en",
										bookingDate: LooponDate(date: bookingDate, formatMode: .dateOnly),
										checkinDate: LooponDate(date: checkinDate, formatMode: .dateOnly),
										checkoutDate: LooponDate(date: checkoutDate, formatMode: .dateOnly),
										status: journeyStage)
	}

	override func viewDidLoad()
	{
		super.viewDidLoad()

		let today = Date()
		let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today

		let bookingDatePicker = UIDatePicker()
		bookingDatePicker.setDate(today, animated: false)
		bookingDatePicker.datePickerMode = .date
		bookingDatePicker.addTarget(self, action: #selector(SetupDemoViewController.didChangeDatePicker(_:)), for: .valueChanged)
		textFieldBookingDate.inputView = bookingDatePicker
		didChangeDatePicker(bookingDatePicker)

		let checkinDatePicker = UIDatePicker()
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

	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)

		labelUnitName.text = pickedUnit?.name ?? "No Unit Selected"
	}

	@objc private func didChangeDatePicker(_ sender: UIDatePicker?)
	{
		if sender === textFieldBookingDate.inputView, let bookingDate = sender?.date
		{
			textFieldBookingDate.text = dateFormatter.string(from: bookingDate)

			if let checkinPicker = textFieldCheckinDate.inputView as? UIDatePicker
			{
				checkinPicker.minimumDate = bookingDate
				didChangeDatePicker(checkinPicker)
			}
		}
		else if sender === textFieldCheckinDate.inputView, let checkinDate = sender?.date
		{
			textFieldCheckinDate.text = dateFormatter.string(from: checkinDate)

			if let checkoutPicker = textFieldCheckoutDate.inputView as? UIDatePicker
			{
				checkoutPicker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: checkinDate)
				didChangeDatePicker(checkoutPicker)
			}
		}
		else if sender === textFieldCheckoutDate.inputView, let checkoutDate = sender?.date
		{
			textFieldCheckoutDate.text = dateFormatter.string(from: checkoutDate)
		}
	}

	@IBAction func done(_ sender: Any?)
	{
		if let demoData = self.demoData
		{
			doneCallback?(demoData)
		}
		else
		{
			print("Did not produce demo data!!!")
		}

		dismiss(animated: true, completion: nil)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if segue.identifier == "PickUnit", let controller = segue.destination as? UnitPickerViewController
		{
			controller.selectionCallback =
				{
					[weak self] pickedUnit in self?.pickedUnit = pickedUnit
				}
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
	var guestJourneyValue: HotelBackend.StayPayload.JourneyStage?
	{
		return HotelBackend.StayPayload.JourneyStage(rawValue: selectedSegmentIndex)
	}
}
