//
//  ChatViewController.swift
//  GuestChat
//
//  Created by Bruno Resende on 17/11/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import UIKit
import ChatWow
import LooponKit

class ChatViewController: ChatWowViewController
{
	private var guestStay: LooponGuestStay? = nil
	{
		didSet
		{
			title = "Chat: \(guestStay?.guest?.name ?? "Anonymous")"
		}
	}

	private var demoData: HotelBackend.StayPayload? = nil
	{
		didSet
		{
			if demoData != nil
			{
				startChat()
				inputController.isEnabled = true
				inputController.setPlaceholder("Type here to chat")
			}
			else
			{
				clearChatLog()
				inputController.isEnabled = false
				inputController.setPlaceholder("Tap “Setup” to start")
			}
		}
	}

	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

		demoData = nil
	}

	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)
	}

	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if segue.identifier == "SetupDemo",
			let navController = segue.destination as? UINavigationController,
			let demoController = navController.viewControllers[0] as? SetupDemoViewController
		{
			demoController.doneCallback =
				{
					[weak self] demoData in self?.demoData = demoData
				}
		}

		super.prepare(for: segue, sender: sender)
	}

	@IBAction func setupDemo(_ sender: Any?)
	{
		demoData = nil
		performSegue(withIdentifier: "SetupDemo", sender: self)
	}

	private func clearChatLog()
	{

	}

	private func startChat()
	{
		guard let demoData = self.demoData else
		{
			return
		}

		do
		{
			try AppDelegate.instance.hotelBackend.postStay(guestData: demoData)
				{
					[weak self] response in

					switch response
					{
					case .success(let stay):
						self?.guestStay = stay
					case .error(let error, let data):
						print("Could not register guest stay! \(error)")

						if let data = data
						{
							let bodyString = String(data: data, encoding: .utf8) ?? data.description
							print("Failed because: \(bodyString)")
						}
					}
				}
		}
		catch
		{
			print("Could not register guest stay! \(error)")
		}
	}
}

