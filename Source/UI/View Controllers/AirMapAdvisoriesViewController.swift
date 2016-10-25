//
//  AirMapAdvisoriesViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 10/25/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class AirMapAdvisoriesViewController: UITableViewController {
	
	var status: Variable<AirMapStatus>!
	
	private typealias AdvisoriesSectionModel = SectionModel<AirMapStatus.StatusColor, AirMapStatusAdvisory>
	private let dataSource = RxTableViewSectionedReloadDataSource<AdvisoriesSectionModel>()
	private let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupTable()
		setupBindings()
	}
	
	private func setupTable() {
		
		tableView.delegate = nil
		tableView.dataSource = nil
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 50
		
		dataSource.configureCell = { dataSource, tableView, indexPath, advisory in
			tableView.cellWith(advisory, at: indexPath) as AirMapAdvisoryCell
		}
		
		dataSource.titleForHeaderInSection = { dataSource, section in
			dataSource.sectionAtIndex(section).model.description
		}
	}
	
	private func setupBindings() {
		
		status.asDriver()
			.map(sectionModel)
			.drive(tableView.rx_itemsWithDataSource(dataSource))
			.addDisposableTo(disposeBag)
	}
	
	private func sectionModel(status: AirMapStatus) -> [AdvisoriesSectionModel] {
		
		return AirMapStatus.StatusColor.allColors
			.map { color in
				AdvisoriesSectionModel(model: color, items: status.advisories.filter { $0.color == color } )
			}
			.filter { section in
				section.items.count > 0
			}
	}
	
	deinit {
		print("deinit")
	}
}
