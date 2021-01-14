//
//  UsersTableViewController.swift
//  MessageMe
//
//  Created by PuNeet on 26/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import UIKit

class UsersTableViewController: UITableViewController {
    
    var allUsers: [User] = []
    var filteredUsers: [User] = []
    
    var searchController = UISearchController(searchResultsController:  nil)
    
    //MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView()
        //  createDummyUser()
        setUpSearchController()
        self.downloadUsers()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    //MARK: Setup Search COntroller
    private func setUpSearchController(){
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search user"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        
    }
    
    
    //MARK: UIScrollView Delegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.refreshControl!.isRefreshing{
            self.downloadUsers()
            self.refreshControl!.endRefreshing()
        }
    }
    private func filteredContentForSearchText(searchText: String){
        //     print("seraching for \(searchText)")
        filteredUsers = allUsers.filter({ (user) -> Bool in
            return user.userName.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    //MARK: Downlaod Users
    private func downloadUsers(){
        FirebaseUserListener.shared.downloadAllUserFormFirebase { (allFirebaseUser) in
            self.allUsers = allFirebaseUser
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredUsers.count : allUsers.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserTableViewCell
        let user = searchController.isActive ? filteredUsers[indexPath.row] : allUsers[indexPath.row]
        cell.confogureOf(user: user)
        // Configure the cell...
        
        return cell
    }
    
    
    //MARK: Tableview delegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableViewBackground")
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    
        let user = searchController.isActive ? filteredUsers[indexPath.row] : allUsers [indexPath.row]
        
        self.showUsersProfile(user: user)
        
    }
    
    //MARK: Navigation
    
    private func showUsersProfile(user: User){
        
        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileTableViewController") as! ProfileTableViewController
        profileView.user = user
        self.navigationController?.pushViewController(profileView,animated: true)

    }
}


extension UsersTableViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }

}
