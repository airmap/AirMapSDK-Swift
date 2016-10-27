//
//  AirMapCreateAircraftViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/27/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class AirMapCreateAircraftViewController: UITableViewController {

	@IBOutlet var nextButton: UIButton!
	@IBOutlet weak var nickName: UITextField!
	@IBOutlet weak var makeAndModel: UILabel!
	@IBOutlet weak var makeAndModelCell: UITableViewCell!
	
	enum EditMode {
		case Create
		case Update
	}
	
	var aircraft = AirMapAircraft()

	private var mode: EditMode {
		return aircraft.aircraftId == nil ? .Create : .Update
	}
	
	private let activityIndicator = ActivityIndicator()
	private var model = Variable(nil as AirMapAircraftModel?)
	private let disposeBag = DisposeBag()
	
	override var navigationController: AirMapAircraftNavController? {
		return super.navigationController as? AirMapAircraftNavController
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		switch mode {
		case .Create:
			navigationItem.title = "Create Aircraft"
			
		case .Update:
			navigationItem.title = "Update Aircraft"
			tableView.allowsSelection = false
			nickName.text = aircraft.nickname
			model.value = aircraft.model
			makeAndModelCell.accessoryType = .None
			makeAndModelCell.textLabel?.alpha = 0.5
		}
		setupBindings()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		if (nickName.text ?? "").isEmpty || mode == .Update {
			nickName.becomeFirstResponder()
		} else {
			self.becomeFirstResponder()
		}
	}
	
	override func canBecomeFirstResponder() -> Bool {
		return true
	}
	
	override var inputAccessoryView: UIView? {
		return nextButton
	}
	
	private func setupBindings() {

		nickName.rx_text.asObservable()
			.subscribeNext { [weak self] name in
				self?.aircraft.nickname = name
			}
			.addDisposableTo(disposeBag)
		
		model.asObservable()
			.unwrap()
			.doOnNext { [unowned self] model in
				self.aircraft.model = model
			}
			.map { [$0.manufacturer.name, $0.name].flatMap { $0 }.joinWithSeparator(" ") }
			.bindTo(makeAndModel.rx_text)
			.addDisposableTo(disposeBag)
		
		Observable.combineLatest(model.asObservable(), nickName.rx_text.asObservable()) {
			$0 != nil && !$1.isEmpty
			}
			.bindTo(nextButton.rx_enabled)
			.addDisposableTo(disposeBag)
		
		activityIndicator.asObservable()
			.throttle(0.25, scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.bindTo(rx_loading)
			.addDisposableTo(disposeBag)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "modalModel" {
			let nav = segue.destinationViewController as! AirMapAircraftModelNavController
			nav.aircraftModelSelectionDelegate = self
		}
	}
	
	@IBAction func unwindToCreateAircraft(segue: UIStoryboardSegue) { /* Interface Builder hook; keep */ }
	
	@IBAction func save() {
		
		let action: Observable<AirMapAircraft>
		switch mode {
		case .Create:
			action = AirMap.rx_createAircraft(aircraft).trackActivity(activityIndicator)
		case .Update:
			action = AirMap.rx_updateAircraft(aircraft).trackActivity(activityIndicator)
		}

		action.doOnCompleted { [weak self] _ in
				self?.navigationController?.aircraftDelegate?
					.aircraftNavController(self!.navigationController!, didCreateOrModify: self!.aircraft)
			}
			.subscribe()
			.addDisposableTo(disposeBag)
	}
	
}

extension AirMapCreateAircraftViewController: AirMapAircraftModelSelectionDelegate {
	
	func didSelectAircraftModel(model: AirMapAircraftModel?) {
		self.model.value = model
		dismissViewControllerAnimated(true, completion: nil)
	}

}
