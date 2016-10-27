//
//  AirMapPhoneCountryViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/8/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

protocol AirMapPhoneCountrySelectorDelegate: class {
	func phoneCountrySelectorDidSelect(country name: String, country code: String)
	func phoneCountrySelectorDidCancel()
}

class AirMapPhoneCountryViewController: UITableViewController {
	
	weak var selectionDelegate: AirMapPhoneCountrySelectorDelegate?
	
	var locale: NSLocale!
	var selectedCountryIdentifier: String!
	
	private var selectedCountryName: String! {
		return self.locale.displayNameForKey(NSLocaleCountryCode, value: self.selectedCountryIdentifier)!
	}
	
	private typealias RowData = (code: String, name: String)
	private let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String,RowData>>()
	private let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupTable()
	}
	
	func setupTable() {
		
		tableView.dataSource = nil
		tableView.delegate = nil
		tableView.rx_setDelegate(self)

		let currentCountry: RowData = (code: selectedCountryIdentifier, name: selectedCountryName)
		
		let otherCountries: [RowData] = NSLocale.ISOCountryCodes()
			.map { ($0, self.locale.displayNameForKey(NSLocaleCountryCode, value: $0)!) }
			.sort { $0.name < $1.name }
		
		let sections = [
			SectionModel(model: "Selected Country", items: [currentCountry]),
			SectionModel(model: "Other", items: otherCountries)
		]
		
		Observable.just(sections)
			.bindTo(tableView.rx_itemsWithDataSource(dataSource))
			.addDisposableTo(disposeBag)
		
		dataSource.configureCell = { datasource, tableView, indexPath, row in
			let cell = tableView.dequeueReusableCellWithIdentifier("phoneCountryCell")!
			cell.textLabel?.text = row.name
			return cell
		}
		
		tableView.rx_itemSelected.asObservable()
			.map(tableView.rx_modelAtIndexPath)
			.subscribeNext { [weak self] (row: RowData) in
				self?.selectionDelegate?.phoneCountrySelectorDidSelect(country: row.name, country: row.code)
			}
			.addDisposableTo(disposeBag)
	}
	
	// MARK: - UITableViewDelegate
	
	override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		
		if indexPath.section == 0 {
			cell.accessoryType = .Checkmark
		} else {
			cell.accessoryType = .None
		}
	}
	
}
