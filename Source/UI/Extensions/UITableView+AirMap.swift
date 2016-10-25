//
//  UITableView+AirMap.swift
//  AirMap
//
//  Created by Adolfo Martinelli on 7/9/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

protocol Dequeueable {
	static var reuseIdentifier: String { get }
}

extension Dequeueable {
	static var reuseIdentifier: String {
		return String(Self)
	}
}

protocol ObjectAssignable {
	associatedtype ObjectType
	func setObject(object: ObjectType?)
}

extension UITableView {
	
	func dequeueCell<T: Dequeueable>(at indexPath: NSIndexPath) -> T {
		return self.dequeueReusableCellWithIdentifier(T.reuseIdentifier, forIndexPath: indexPath) as! T
	}
	
	func cellWith
		<T: ObjectAssignable where T: Dequeueable, T: UITableViewCell>
		(object: T.ObjectType?, at indexPath: NSIndexPath) -> T {
		
		let cell = dequeueReusableCellWithIdentifier(T.reuseIdentifier, forIndexPath: indexPath) as! T
		cell.setObject(object)
		return cell
	}
	
	func deselectSelectedRows(animated: Bool) {
		for indexPath in indexPathsForSelectedRows ?? [] {
			deselectRowAtIndexPath(indexPath, animated: animated)
		}
	}
}
