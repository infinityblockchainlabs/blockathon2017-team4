//
//  LenderDashboardViewController.swift
//  BlockathonDemo
//
//  Created by Vanalite on 11/25/17.
//  Copyright © 2017 Vanalite. All rights reserved.
//

import UIKit
import SWRevealViewController

class LenderDashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, BorrowerCellDelegate, BidLoanOrderViewDelegate {

	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var hamburgerButton: UIButton!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var etherBalanceLabel: UILabel!
	@IBOutlet weak var tokenBalanceLabel: UILabel!

	var rateView: BidLoanOrderView?
	lazy var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action:
			#selector(LenderDashboardViewController.handleRefresh(_:)),
														 for: UIControlEvents.valueChanged)

		return refreshControl
	}()
	var swrevealViewController: SWRevealViewController {
		return revealViewController()
	}

	var borrowerList: [User] = [];
	var creditList: [Credit] = []
	var user: User!
	var currentLowestBid = 12.0

	override func viewDidLoad() {
		super.viewDidLoad()
		user = DataManager.shared.currentUser

		self.initUI()
	}

	func initUI() {
		self.hamburgerButton.isHidden = false
		self.backButton.isHidden = true
		hamburgerButton.addTarget(swrevealViewController, action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
		view.addGestureRecognizer(swrevealViewController.panGestureRecognizer())
		self.tableView.register(UINib(nibName: "BorrowerCell", bundle: nil), forCellReuseIdentifier: "BorrowerCellIdentifier")
		self.tableView.separatorStyle = .none
		self.tableView.addSubview(self.refreshControl)
		self.profileImageView.layer.cornerRadius = 40.0
		self.profileImageView.layer.masksToBounds = true;
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
		self.reloadData()
		if (self.swrevealViewController.frontViewPosition != FrontViewPosition.left) {
			self.swrevealViewController.revealToggle(animated: false)
		}
	}

	func reloadData() {
		self.user.requestUserData { (user, error) in
			self.user = user
			self.user.requestUserEtherBalance { (user, error) in
				self.user = user
				self.populateData()
			}

			self.user.requestUserTokenBalance { (user, error) in
				self.user = user
				self.populateData()
			}
		}
		self.user.requestAllUser { (userList, error) in
			DataManager.shared.userList = userList
			self.borrowerList = userList.filter({ (user) -> Bool in
				return user.userType == "borrower"
			})

			Credit.requestAllCredit(user: self.user, completion: { (creditList, error) in
				DataManager.shared.creditList = creditList
				self.creditList = []
				for credit in creditList {
					if (credit.expired == "false" && credit.status == "created" && credit.borrowerId != self.user.id) {
						self.creditList.append(credit)
					}
				}
				self.tableView.reloadData()
			})

		}
	}

	func populateData() {
		if !user.username.isEmpty {
			self.nameLabel.text = user.username
		}
		if (user.ETHBalance >= Double(0.0)) {
			self.etherBalanceLabel.text = "\(user.ETHBalance) ETH"
		} else {
			self.etherBalanceLabel.text = "Loading..."
		}
		if (user.tokenBalance >= Double(0.0)) {
			self.tokenBalanceLabel.text = "$\(user.tokenBalance)"
		} else {
			self.tokenBalanceLabel.text = "Loading..."
		}
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 150.0;
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return creditList.count;
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: "BorrowerCellIdentifier") as? BorrowerCell {
			let credit = self.creditList[indexPath.row]
			cell.avatarImage.image = UIImage.init(named: "borrower\(indexPath.row)")
			if let borrower = credit.borrower {
				cell.nameLabel.text = borrower.username
			}
			cell.expectInterestLabel.text = "\(credit.rate)% per month"
			cell.lendValueLabel.text = "$\(credit.amount)"
			cell.delegate = self
			return cell;
		}
		return UITableViewCell();
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performBidRate(indexPath: indexPath)
	}

	func borrowerCellDidTapBidRate(cell: BorrowerCell) {
		let indexPath = tableView.indexPath(for: cell)
		let credit = creditList[(indexPath?.row)!]
		rateView = Bundle.main.loadNibNamed("BidLoanOrderView", owner: self, options: nil)?[0] as? BidLoanOrderView
		if let rateView = rateView {
			rateView.credit = credit
			rateView.frame = self.view.bounds
			rateView.awakeFromNib()
			rateView.populateData()
			rateView.delegate = self
			self.view.addSubview(rateView)
		}
//		self.performBidRate(indexPath: indexPath!)
	}

	func performBidRate(indexPath: IndexPath) {
		let alertController = UIAlertController(title: "Bid interest", message: "Enter the interest rate you want to bid\nCurrent lowest bid rate: \(currentLowestBid)%", preferredStyle: UIAlertControllerStyle.alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction) in
			self.tableView.deselectRow(at: indexPath, animated: true)
			alertController.dismiss(animated: true, completion: nil)
		}))

		alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) in
			let interestRateBidTextField = alertController.textFields![0] as UITextField
			let interestRateBid : Double = NSString(string: interestRateBidTextField.text!).doubleValue
			if (interestRateBid < self.currentLowestBid) {
				DataManager.shared.currentUser = self.user
//				let biddingCredit = creditList[indexPath.row]
//				biddingCredit.requestBidCredit(bidRate: interestRateBid, completion: { (error) -> Void? in
//					if (error) {
//
//					} else {
//
//					}
//				})
				self.performSegue(withIdentifier: "LenderDashboardToHistorySegue", sender: self)
			} else {
				print("Failed")
			}
			self.tableView.deselectRow(at: indexPath, animated: true)
			alertController.dismiss(animated: true, completion: nil)
		}))

		alertController.addTextField { (textField : UITextField!) in
			textField.placeholder = "Enter Bidding Interest Rate"
		}

		present(alertController, animated: true, completion: nil)
	}

	func handleRefresh(_ refreshControl: UIRefreshControl) {
		reloadData()
		refreshControl.endRefreshing()
	}

	func bidLoanOrderViewDidTapCancel(bidLoanOrderView: BidLoanOrderView) {

	}

	func bidLoanOrderViewDidTapOK(bidLoanOrderView: BidLoanOrderView) {
		let interestRateBid : Double = NSString(string: bidLoanOrderView.bidRateTextField.text!).doubleValue
		if (interestRateBid < self.currentLowestBid) {
			DataManager.shared.currentUser = self.user
			//				let biddingCredit = creditList[indexPath.row]
			//				biddingCredit.requestBidCredit(bidRate: interestRateBid, completion: { (error) -> Void? in
			//					if (error) {
			//
			//					} else {
			//
			//					}
			//				})
			bidLoanOrderView.removeFromSuperview()
			self.performSegue(withIdentifier: "LenderDashboardToHistorySegue", sender: self)

		}
	}
}
