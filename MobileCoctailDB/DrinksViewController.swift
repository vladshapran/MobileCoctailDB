//
//  ViewController.swift
//  MobileCocktail
//
//  Created by Владислав on 9/5/20.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

//MARK: - SaveFilterDelegate
protocol SaveFilterDelegate: class {
    func save(category: Result)
}

class DrinksViewController: UIViewController, SaveFilterDelegate {
    
    @IBOutlet weak var drinksTableView: UITableView!
    
    let spinner = UIActivityIndicatorView(style: .gray)
    var dictionaryCategory: Result?
    var drinkDownloadedData: [AllDrinks]? = []
    var urlString: String!
    var index: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SettingTableAndGetData()
    }
    
    func SettingTableAndGetData() {
        drinksTableView.dataSource = self
        drinksTableView.delegate = self
        self.getFilterData()
        sleep(1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        index = 0
        drinkDownloadedData?.removeAll()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getDrink()
    }
    
    func getFilterData() {
        let urlString = "https://www.thecocktaildb.com/api/json/v1/1/list.php?c=list"
        guard let url = URL(string: urlString) else { return }
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                var category = try JSONDecoder().decode(Result.self, from: data)
                for i in 0..<category.drinks.count  {
                    category.drinks[i].strCategory = category.drinks[i].strCategory
                        .components(separatedBy: " ")
                        .filter {!$0.isEmpty}
                        .joined(separator: "_")
                    category.drinks[i].selectCat = true
                }
                self.dictionaryCategory = category
            } catch {
                print(error)
            }
            } .resume()
    }
    
    func getDrink() {
        if index >= (dictionaryCategory?.drinks.count ?? 0) {
            self.drinksTableView.tableFooterView?.isHidden = true
            spinner.stopAnimating()
            self.drinksTableView.tableFooterView = .none
        } else if dictionaryCategory?.drinks[index].selectCat == false {
            index += 1
            getDrink()
        } else  if dictionaryCategory?.drinks[index].selectCat == true {
            urlString = "https://www.thecocktaildb.com/api/json/v1/1/filter.php?c="
                + dictionaryCategory!.drinks[index].strCategory
            guard let url = URL(string: urlString) else { return }
            URLSession.shared.dataTask(with: url) { ( data, response, error) in
                guard let data = data else { return }
                do {
                    var json = try JSONDecoder().decode(AllDrinks.self, from: data)
                    json.nameCategory = self.dictionaryCategory?.drinks[self.index].strCategory
                    self.drinkDownloadedData?.append(contentsOf: [json])
                    self.index += 1
                    DispatchQueue.main.async {
                        self.drinksTableView.reloadData()
                    }
                } catch {
                    print(error)
                }
                }.resume()
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Filter" {
            let filterVC = segue.destination as! FiltersViewController
            filterVC.delegate = self
            filterVC.category = dictionaryCategory
        }
    }
    
    func save(category: Result) {
        dictionaryCategory = category
    }
}

extension DrinksViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return drinkDownloadedData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return drinkDownloadedData![section].nameCategory?
            .components(separatedBy: "_")
            .filter {!$0.isEmpty}
            .joined(separator: " ")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drinkDownloadedData?[section].drinks.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Drinks") else {return UITableViewCell()}
        
        cell.textLabel?.text = drinkDownloadedData?[indexPath.section].drinks[indexPath.row].strDrink
        if let imageURL = URL(string: drinkDownloadedData?[indexPath.section].drinks[indexPath.row].strDrinkThumb ?? "default") {
            let data = try? Data(contentsOf: imageURL)
            if let data = data {
                let image = UIImage(data: data )
                DispatchQueue.main.async {
                    cell.imageView?.image = image
                }
            }
        }
        return cell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = drinksTableView.numberOfSections - 1
        let lastRowIndex = drinksTableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: drinksTableView.bounds.width, height: CGFloat(44))
            self.drinksTableView.tableFooterView = spinner
            self.drinksTableView.tableFooterView?.isHidden = false
            getDrink()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
}
