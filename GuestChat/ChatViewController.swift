//
//  ChatViewController.swift
//  GuestChat
//
//  Created by Bruno Resende on 17/11/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import UIKit
import ChatWow

class ChatViewController: ChatWowViewController
{
	private var demoData: SetupDemoViewController.DemoData? = nil
	{
		didSet
		{
			if demoData != nil
			{
				clearChatLog()
			}
			else
			{
				startChat()
			}
		}
	}

	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
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

	}
}

