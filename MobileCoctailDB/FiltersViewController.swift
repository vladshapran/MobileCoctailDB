//
//  FiltersViewController.swift
//  MobileCocktail
//
//  Created by Владислав on 9/5/20.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class FiltersViewController: UIViewController {
    
    @IBOutlet weak var filterTableView: UITableView!
    
    var category: Result?
    weak var delegate: SaveFilterDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterTableView.delegate = self
        filterTableView.dataSource = self
    }
    
    @IBAction func applyCategory(){
        delegate?.save(category: category!)
    }
}


extension FiltersViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return category?.drinks.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Filters") else {return UITableViewCell()}
        cell.textLabel?.font = .systemFont(ofSize: 20)
        cell.textLabel?.text = category?.drinks[indexPath.row].strCategory
            .components(separatedBy: "_")
            .filter {!$0.isEmpty}
            .joined(separator: " ")
        if category?.drinks[indexPath.row].selectCat == true {
            cell.accessoryType.self = .checkmark
        }
        return cell
    }
    
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filterTableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.checkmark {
            filterTableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
            category?.drinks[indexPath.row].selectCat = false
        } else {
            filterTableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
            category?.drinks[indexPath.row].selectCat = true
        }
    }
    
}

