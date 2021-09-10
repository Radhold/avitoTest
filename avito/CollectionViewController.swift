//
//  CollectionViewController.swift
//  avito
//
//  Created by Yaroslav Fomenko on 09.09.2021.
//

import UIKit

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var employees = [Employee]()
    var session = URLSession.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(urlSession))
        navigationItem.rightBarButtonItem?.isEnabled = false
        guard let request = formRequest() else {
            return
        }
        let defaults = UserDefaults.standard
        let time = defaults.double(forKey: "Time")
        if NSDate().timeIntervalSince1970 - time > 3600 {
            session.configuration.urlCache?.removeAllCachedResponses()
            //Чищу куки, потому что кэш сбрасывается только после перезагрузки после истечения времени
            if let cookies = HTTPCookieStorage.shared.cookies {
                for cookie in cookies {
                    HTTPCookieStorage.shared.deleteCookie(cookie)
                }
            }
            defaults.removeObject(forKey: "Time")
        }
        if let cacheResponse = session.configuration.urlCache?.cachedResponse(for: request) {
            parse(json: cacheResponse.data)
            print("load from cache")
        }
        else {
            urlSession()
            print("load from internet")
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
        cell.name.text = "Name: " + employee.name
        cell.number.text = "Number: " + employee.phone_number
        cell.skills.text = "Skills: " + employee.skills.joined(separator: ", ")
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
            employees = jsonResults.company.employees
            employees.sort{$0.name < $1.name}
            DispatchQueue.main.async {
                self.title = jsonResults.company.name
                self.collectionView.reloadData()
            }
        }
    }
    func showErrorAlert() {
        let ac = UIAlertController(title: "Ошибка сети", message: "Произошла ошибка во время загрузки, попробуйте снова", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        ac.popoverPresentationController?.barButtonItem = navigationController?.navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
    
    @objc func urlSession(){
        employees.removeAll()
        guard let request = formRequest() else {
            return
        }
        let time = NSDate().timeIntervalSince1970
        UserDefaults.standard.set(time, forKey: "Time")
        session.dataTask(with: request) {data, response, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    self.title = "Try later"
                    self.collectionView.reloadData()
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.showErrorAlert()
                }
                return
            }
            if let data = data {
                DispatchQueue.main.async {self.navigationItem.rightBarButtonItem?.isEnabled = false}
                DispatchQueue.global().async {
                    self.parse(json: data)
                }
             }
        }.resume()
    }
    
    func formRequest()-> URLRequest? {
        let urlString = "https://run.mocky.io/v3/1d1cb4ec-73db-4762-8c4b-0b8aa3cecd4c"
        guard let url = URL(string: urlString) else {
            return nil
        }
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        return request
        
    }
}
