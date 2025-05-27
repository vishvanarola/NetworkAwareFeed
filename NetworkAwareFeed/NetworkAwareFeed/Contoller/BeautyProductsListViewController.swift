//
//  BeautyProductsListViewController.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

import UIKit

class BeautyProductsListViewController: UIViewController {
    
    //MARK: - Outlet
    @IBOutlet weak var listTableView: UITableView!
    
    //MARK: - Declaration
    var beautyProductListArray: [BeautyProducts] = []
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listTableView.backgroundColor = .clear
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
        self.listTableView.register(UINib(nibName: BeautyProductTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: BeautyProductTableViewCell.identifier)
        self.fetchBeautyProductList()
    }
    
}

//MARK: - Table View Delegate & Data Source
extension BeautyProductsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.beautyProductListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.listTableView.dequeueReusableCell(withIdentifier: BeautyProductTableViewCell.identifier, for: indexPath) as! BeautyProductTableViewCell
        cell.setUpData(img: self.beautyProductListArray[indexPath.row].thumbnail ?? "", title: self.beautyProductListArray[indexPath.row].title ?? "", desc: self.beautyProductListArray[indexPath.row].description ?? "")
        return cell
    }
}

//MARK: - Network Call
extension BeautyProductsListViewController {
    func fetchBeautyProductList() {
        ApiService().beautyProductListApiCall(success: { response in
            
            if let data = response.products {
                self.beautyProductListArray = data
                self.listTableView.reloadData()
            }
            
        }, failure: { error in
            print(error)
        })
    }
}
