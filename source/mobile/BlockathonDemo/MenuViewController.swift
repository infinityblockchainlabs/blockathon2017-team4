//
//  MenuViewController.swift
//  BlockathonDemo
//
//  Created by Vanalite on 11/25/17.
//  Copyright © 2017 Vanalite. All rights reserved.
//

import UIKit
import SWRevealViewController

enum MenuItem: Int {
	case Dashboard = 0
	case History
	case MyProfile
	case Settings
	case SignOut
	case Count

	var stringValue: String {
		switch self {
		case .Dashboard: return "Dashboard"
		case .History: return "History"
		case .MyProfile: return "MyProfile"
		case .Settings: return "Settings"
		case .SignOut: return "SignOut"
		default: return ""
		}
	}

	var iconImage: UIImage? {
		switch self {
		case .Dashboard: return UIImage(named: "MIDashboard")
		case .History: return UIImage(named: "MIHistory")
		case .MyProfile: return UIImage(named: "MIMyProfile")
		case .Settings: return UIImage(named: "MISettings")
		case .SignOut: return UIImage(named: "MISignOut")
		default: return nil
		}
	}

}

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var tableView: UITableView!
	var swrevealViewController: SWRevealViewController {
		return revealViewController()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		initUI()
	}

	func initUI() {
		swrevealViewController.rearViewRevealWidth = Constants.TCMenuWidth
		initTableView()
	}

	func initTableView() {
		tableView.separatorStyle = .none
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 64.0
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return MenuItem.Count.rawValue
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCellIdentifier") as! MenuTableViewCell
		if let menuItem = MenuItem(rawValue: indexPath.row) {
			cell.titleLabel?.text = menuItem.stringValue
			if let image = menuItem.iconImage {
				cell.iconImageView.image = image
			}
		}

		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.row {
		case MenuItem.Dashboard.rawValue:
			fallthrough
		case MenuItem.History.rawValue:
			swrevealViewController.frontViewController.performSegue(withIdentifier: "LenderDashboardToHistorySegue", sender: swrevealViewController.frontViewController)
		case MenuItem.MyProfile.rawValue:
			fallthrough
		case MenuItem.Settings.rawValue:
			fallthrough
		case MenuItem.SignOut.rawValue:
			self.swrevealViewController.frontViewController.navigationController?.popViewController(animated: true)
		default: return
		}
	}
}
