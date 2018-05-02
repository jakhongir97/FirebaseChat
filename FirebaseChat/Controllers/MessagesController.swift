//
//  ViewController.swift
//  FirebaseChat
//
//  Created by Jahongir Nematov on 4/10/18.
//  Copyright © 2018 Jahongir Nematov. All rights reserved.
//

import UIKit
import Firebase
import RxSwift
import RxCocoa
import HGPlaceholders

class MessagesController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var messages : Variable<[Message]> = Variable([])
    var messagesDictionary = [String : Message]()
    
    let disposeBag = DisposeBag()
    
    let cellIdentifier = "cell"
    
    let tableView : UITableView = {
        var tableView = UITableView()
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.backgroundColor = .amazingBlue
        return tableView
    }()

    let logoutButton : UIButton = {
        var button = UIButton()
        button.setImage(UIImage.init(named: "logout")?.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return button
    }()
    
    let addUserButton : UIButton = {
        var button = UIButton()
        button.setImage(UIImage.init(named: "adduser")?.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
        button.widthAnchor.constraint(equalToConstant: 35).isActive = true
        button.heightAnchor.constraint(equalToConstant: 35).isActive = true
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserLoggedIn()
        observeUserMessages()
        setupTableView()
        setupNavbar()
        setupCellConfiguration()
        setupCellTapHandling()
        setupDeleteWithSwipe()
        shouldBeReloaded()
        
    }
    
    private func shouldBeReloaded () {
        UpdateUser.shared.shouldBeReloaded.asObservable().subscribe(onNext: { [weak self] bool in
            if bool {
                self?.fetchUserAndSetupNavBarTitle()
            }
            
        }).disposed(by: disposeBag)
    }
    
    private func setupNavbar(){
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = .amazingBrown
        self.navigationController?.navigationBar.tintColor = .amazingBlue
        let textAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoutButton)
        logoutButton.addTarget(self, action: #selector(handleLogOut), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addUserButton)
        addUserButton.addTarget(self, action: #selector(handleNewMessages), for: .touchUpInside)
    
    }
    
    private func setupTableView() {
        tableView.delegate = self
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        tableView.register(UserCell.self, forCellReuseIdentifier: cellIdentifier)
        
        tableView.separatorStyle = .none
    }
    
    
    
    private func setupCellConfiguration() {
        messages.asObservable()
            .bind(to: tableView
                .rx
                .items(cellIdentifier: cellIdentifier, cellType: UserCell.self)) { row , message , cell in
                    
                    
                    if let id = message.chatPartnerId() {
                        let ref = Database.database().reference().child("users").child(id)
                        ref.observeSingleEvent(of: .value , with: { (snapshot) in
                            if let dictionary = snapshot.value as? [String : AnyObject] {
                                cell.topLabel.text = dictionary["name"] as? String
                                if let urlString = dictionary["profileImageUrl"] as? String {
                                    let url = URL(string: urlString)
                                    cell.profileImageView.kf.indicatorType = .activity
                                    cell.profileImageView.kf.setImage(with: url)
                                } 
                                
                            }
                            
                        }, withCancel: nil)
                    }
                    
                    cell.bottomLabel.text = message.text
                    
                    if let seconds = message.timestamp?.doubleValue {
                        let timestampDate = Date(timeIntervalSince1970: seconds)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "HH:mm"
                        cell.timeLabel.text = dateFormatter.string(from: timestampDate)
                    }
                    
                    
                    
            }.disposed(by: disposeBag)
    }
    
    private func setupCellTapHandling() {
        tableView
            .rx
            .modelSelected(Message.self)
            .subscribe(onNext: {
                message in
                
                guard let chatPartnerId = message.chatPartnerId() else { return }
                let ref = Database.database().reference().child("users").child(chatPartnerId)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
                    
                    var user = User()
                    user.name = dictionary["name"] as? String
                    user.email = dictionary["email"] as? String
                    user.profileImageUrl = dictionary["profileImageUrl"] as? String
                    user.id = chatPartnerId
                    
                    let chatControlller = ChatController()
                    chatControlller.user = user
                    self.navigationController?.pushViewController(chatControlller, animated: true)

                    
                }, withCancel: nil)
                
                if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
                }
                
                
                
            }).disposed(by: disposeBag)
        
    }
    
    private func setupDeleteWithSwipe(){
        tableView
            .rx
            .itemDeleted
            .subscribe{
                guard let indexPath = $0.element else { return }
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let message = self.messages.value[indexPath.row]
                if let chatPartnerId = message.chatPartnerId() {
                    Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        
                        self.messages.value.remove(at: indexPath.row)
                        self.messagesDictionary.removeValue(forKey: chatPartnerId)
                        
                        print("deleted")
                    })
                }
                
                
                
            }.disposed(by: disposeBag)
        
    }
    
    func observeUserMessages(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                let messageReference = Database.database().reference().child("messages").child(messageId)
                
                messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String : AnyObject] {
                        var message = Message()
                        message.fromId = dictionary["fromId"] as? String
                        message.text = dictionary["text"] as? String
                        message.timestamp = dictionary["timestamp"] as? NSNumber
                        message.toId = dictionary["toId"] as? String
                        
                        if let chatPartnerId = message.chatPartnerId() {
                            self.messagesDictionary[chatPartnerId] = message
                            
                            self.messages.value = Array(self.messagesDictionary.values)
                            
                            self.messages.value.sort(by: { (message1, message2) -> Bool in
                                return message1.timestamp!.intValue >= message2.timestamp!.intValue
                            })
                        }
                    }
                    
                }, withCancel: nil)
            }, withCancel: nil)
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            self.messagesDictionary.removeValue(forKey: snapshot.key)
        }, withCancel: nil)
    }
    
   
    
    
    
    func checkIfUserLoggedIn (){
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogOut), with: nil, afterDelay: 0)
        }else {
            self.fetchUserAndSetupNavBarTitle()
            
        }
        
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : Any] {
                self.navigationItem.title = dictionary["name"] as? String
                self.observeUserMessages()
            }
        }, withCancel: nil)
    }
    
    @objc func handleNewMessages(){
        let newMessagesController = NewMessagesController()
        navigationController?.pushViewController(newMessagesController, animated: true)
        
    }

    @objc func handleLogOut(){
        do {
            try Auth.auth().signOut()
            if !messagesDictionary.isEmpty {
                self.messagesDictionary.removeAll(keepingCapacity: false)
                self.messages.value.removeAll(keepingCapacity: false)
            }
        } catch let error {
            print(error)
        }
        
        
        let phoneNumberViewCotroller = PhoneNumberViewCotroller()
        present(phoneNumberViewCotroller, animated: false, completion: nil)
        
        
    }
  

}

extension MessagesController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
     
}


