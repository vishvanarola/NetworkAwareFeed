//
//  ReviewsViewController.swift
//  NetworkAwareFeed
//
//  Created by apple on 03/06/25.
//

import UIKit

class ReviewsViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var listTableView: UITableView!
    
    // MARK: - Properties
    var reviewsData = [ReviewsData]()
    var fetchedData = [ReviewsData]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            // Suppose this is the loaded data
            self.reviewsData = self.fetchedData
            self.reloadTableWithAnimation()
        }
    }
    
    private func setupTableView() {
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.register(UINib(nibName: ReviewsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ReviewsTableViewCell.identifier)
        listTableView.separatorStyle = .none
        listTableView.backgroundColor = .systemBackground
    }
    
    func reloadTableWithAnimation() {
        self.listTableView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.listTableView.alpha = 1.0
        }
        self.listTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    // MARK: - Actions
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ReviewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReviewsTableViewCell.identifier, for: indexPath) as! ReviewsTableViewCell
        cell.setUpData(rating: reviewsData[indexPath.row].rating ?? 0, date: reviewsData[indexPath.row].date ?? "", comment: reviewsData[indexPath.row].comment ?? "", name: reviewsData[indexPath.row].reviewerName ?? "")
        return cell
    }
}
