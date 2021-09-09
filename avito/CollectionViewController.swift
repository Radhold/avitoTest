//
//  CollectionViewController.swift
//  avito
//
//  Created by Yaroslav Fomenko on 09.09.2021.
//

import UIKit

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var employees = [Employee]()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        let urlString = "https://run.mocky.io/v3/1d1cb4ec-73db-4762-8c4b-0b8aa3cecd4c"
        let defaults = UserDefaults.standard
        guard let url = URL(string: urlString) else {
            return
        }
        let cache = NSCache<NSString, CompanyData>()
        if let cachedVersion = cache.object(forKey: "Cached") {
            if let time = defaults.object(forKey: "Time") as? Date {
                if time.timeIntervalSinceNow < 3600  {
                    employees = cachedVersion.company.employees
                    title = cachedVersion.company.name
                }
                else {
                    urlSeccsion(url: url)
                }
            }
        }
        else {
            urlSeccsion(url: url)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return employees.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell.")
        }
        let employee = employees[indexPath.item]
        cell.name.text! += employee.name
        cell.number.text! += employee.phone_number
        cell.skills.text! += employee.skills.joined(separator: ", ")
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.cornerRadius = 10
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let cellSize = CGSize(width: collectionView.bounds.width - 2*10, height: 120)
        return cellSize
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()

        if let jsonResults = try? decoder.decode(CompanyData.self, from: json) {
            print(type(of: jsonResults))
            employees = jsonResults.company.employees
            employees.sort{$0.name < $1.name}
            let cache = NSCache<NSString, CompanyData>()
            cache.setObject(jsonResults, forKey: "Cached")
            let defaults = UserDefaults.standard
            let time = Date().timeIntervalSince1970
            defaults.set(time, forKey: "Time")
            DispatchQueue.main.async {
                self.title = jsonResults.company.name
                self.collectionView.reloadData()
            }
        }
    }
    func showErrorAlert() {
        let ac = UIAlertController(title: "Ошибка сети", message: "Произошла ошибка во время загрузки, попробуйте снова", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func urlSeccsion(url: URL){
        URLSession.shared.dataTask(with: url) {data, response, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    self.title = "Try later"
                    self.showErrorAlert()
                }
                return
            }
            if let data = data {
                self.parse(json: data)
             }
        }.resume()
    }
}
