//
//  NewMessagesController.swift
//  FirebaseChat
//
//  Created by Jahongir Nematov on 4/11/18.
//  Copyright © 2018 Jahongir Nematov. All rights reserved.
//

import UIKit
import Firebase
import RxSwift
import RxCocoa
import SnapKit
import Kingfisher

class NewMessagesController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var users : Variable<[User]> = Variable([])
    
    let cellIdentifier = "cell"
    let disposeBag = DisposeBag()
    
    let tableView : UITableView = {
        var tableView = UITableView()
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        fetchUser()
        setupCellConfiguration()
        setupCellTapHandling()

    }
    
    private func setupView(){
        
        navigationItem.title = "New Messages"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        view.backgroundColor = UIColor.amazingBlue
        
        tableView.delegate = self
        tableView.backgroundColor = UIColor.amazingBlue
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        tableView.separatorStyle = .none
        tableView.register(UserCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    private func setupCellConfiguration() {
        users.asObservable()
        .bind(to: tableView
        .rx
        .items(cellIdentifier: cellIdentifier, cellType: UserCell.self)) { row , user , cell in
            cell.topLabel.text = user.name
            cell.bottomLabel.text = user.email
            guard let urlString = user.profileImageUrl else {return}
            let url = URL(string: urlString)
            cell.profileImageView.kf.indicatorType = .activity
            cell.profileImageView.kf.setImage(with: url)
            
        }.disposed(by: disposeBag)
    }
    
    private func setupCellTapHandling() {
        tableView
            .rx
            .modelSelected(User.self)
            .subscribe(onNext: {
                user in
                
                if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
                }
                
                let chatControlller = ChatController()
                chatControlller.user = user
                self.navigationController?.pushViewController(chatControlller, animated: true)

            }).disposed(by: disposeBag)

    }
    
    private func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                var user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                user.id = snapshot.key
                
                self.users.value.append(user)
            }

        }, withCancel: nil)
    }

  

}

extension NewMessagesController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
