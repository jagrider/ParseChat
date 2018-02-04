//
//  ChatViewController.swift
//  ParseChat
//
//  Created by Jonathan Grider on 1/30/18.
//  Copyright © 2018 Jonathan Grider. All rights reserved.
//

import UIKit
import Parse

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var messageField: UITextField!
  @IBOutlet weak var tableView: UITableView!
  let logoutAlert = UIAlertController(title: "Confirm", message: "Are you sure you want to log out?", preferredStyle: .alert)
  
//  let anonymousUsers: [String] = ["🐶", "🐱", "🐰", "🐭", "🐹", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐒", "🐔", "🐧", "🐦", "🐤", "🐥", "🦆", "🦅", "🦉", "🦇", "🐺", "🐗", "🐴", "🦄", "🐝", "🐛", "🦋", "🐌", "🐞", "🐜", "🕷", "🦂", "🐢", "🐍", "🦎", "🦖", "🦕", "🐙", "🦑", "🦐", "🦀", "🐡", "🐠", "🐟", "🐬", "🐳", "🐋", "🦈", "🐊", "🐅", "🐆", "🦓", "🦍", "🐘", "🦏", "🐪", "🐫", "🦒", "🐃", "🐂", "🐄", "🐎", "🐖", "🐏", "🐑", "🐐", "🦌", "🐕", "🐩", "🐈", "🐓", "🦃", "🕊", "🐇", "🐁", "🐀", "🐿", "🦔", "🐲"]
  var messages: [PFObject] = []
  var refreshController: UIRefreshControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    tableView.delegate = self
    
    let logoutAction = UIAlertAction(title: "Log Out", style: .destructive) { (action) in
      NotificationCenter.default.post(name: NSNotification.Name("didLogout"), object: nil)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
      // Do nothing; dismisses the view
    }
    logoutAlert.addAction(logoutAction)
    logoutAlert.addAction(cancelAction)
    
    // Auto size row height based on cell autolayout constraints
    tableView.rowHeight = UITableViewAutomaticDimension
    
    // Provide an estimated row height. Used for calculating scroll indicator
    tableView.estimatedRowHeight = 70
    
    // Set up refresh controller
    refreshController = UIRefreshControl()
    refreshController.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
    tableView.insertSubview(refreshController, at: 0)
    
    // Pull the chat messages
    self.getMessages()
    
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell
    
    //let randNum = Int(arc4random_uniform(_: UInt32(anonymousUsers.count)))
    //let anonymousEmoji = anonymousUsers[randNum]
    
    cell.chatLabel.text = messages[indexPath.row]["text"] as! String?
    if let user = messages[indexPath.row]["user"] as? PFUser {
      cell.userLabel.text = user.username
    } else {
      cell.userLabel.text = "Anonymous 🤖"
    }
    
    return cell
  }
  
  @IBAction func sendPressed(_ sender: Any) {
    
    // Shut down the keyboard
    self.messageField.resignFirstResponder()
    
    let chatMessage = PFObject(className: "Message")
    chatMessage["user"] = PFUser.current()
    chatMessage["text"] = messageField.text ?? ""
    
    chatMessage.saveInBackground { (success, error) in
      if success {
        print("The message was saved!")
        
        // Clear the message text field
        self.messageField.text = ""
        
      } else if let error = error {
        print("Problem saving message: \(error.localizedDescription)")
      }
    }
    
    getMessages()
  }
  
  @IBAction func onLogOut(_ sender: Any) {
    present(logoutAlert, animated: true) {
      // If they tap Logout, the notificaiton will be sent to the app to log them out.
    }
  }
  
  @objc func refreshControlAction(_ refreshControl: UIRefreshControl) {
    
    // Reload the list of messages
    getMessages()
    
    // Reload the tableView now that there is new data
    tableView.reloadData()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
      // Stop the refresh controller
      self.refreshController.endRefreshing()
    }
    
  }
  
//  func updateColors() {
//    tableView.separatorStyle = .none
//
//  }
  
  @objc func getMessages() {
    let query = PFQuery(className: "Message")
    query.includeKey("user")
    query.addDescendingOrder("createdAt")
    
    // fetch data asynchronously
    query.findObjectsInBackground { (messages: [PFObject]?, error: Error?) in
      if error != nil {
        print("Error: \(error?.localizedDescription ?? "")")
      } else {
        self.messages = messages!
        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}
