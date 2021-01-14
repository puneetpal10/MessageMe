//
//  ChatsTableViewController.swift
//  MessageMe
//
//  Created by PuNeet on 29/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import UIKit

class ChatsTableViewController: UITableViewController {
    
    
    let searchController = UISearchController(searchResultsController: nil)
    //MARK:  Vars
    
    var allRecents: [RecentChat] = []
    var filteredRecents: [RecentChat] = []
    
    //MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        self.downloadRecentChat()
        self.setupSearchController()
    }
    
    
    private func setupSearchController(){
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search user"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }
    
    @IBAction func composeBarButtonPressed(_ sender: Any) {
        
        let usersView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "UsersTableViewController") as! UsersTableViewController
        self.navigationController?.pushViewController(usersView, animated: true)
    }
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchController.isActive ? filteredRecents.count : self.allRecents.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecentTableViewCell
        let recent = searchController.isActive ? filteredRecents[indexPath.row] : self.allRecents[indexPath.row]
        cell.configure(recent: recent)
        
        // Configure the cell...
        
        return cell
    }
    
    //MARK: TableView Delegate
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let recent = searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row]
            FirebaseRecentListener.shared.delete(recent)
            searchController.isActive ? self.filteredRecents.remove(at: indexPath.row) : self.allRecents.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
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
        
        let recent = searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row]
        
        FirebaseRecentListener.shared.clearUnreadCount(recent)
        
        goToChat(recent)

        
    }
    
    //MARK: Download chats
    private func downloadRecentChat(){
        FirebaseRecentListener.shared.downloadRecentChatFromFireStore { (allChats) in
            self.allRecents = allChats
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func filteredContentForSearchText(searchText: String){
        filteredRecents = allRecents.filter({(recent) -> Bool in
            return recent.receiverName.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    
    //MARK: Navigation
    private func goToChat(_ recent: RecentChat){
        
        restartChat(chatRoomId: recent.chatRoomId, memberIds: recent.memberIds)
        let privateChatView = ChatViewController(chatId: recent.chatRoomId, recepientId: recent.receiverId, recepientName: recent.receiverName)
        privateChatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(privateChatView, animated: true)
    }
}


extension ChatsTableViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}

