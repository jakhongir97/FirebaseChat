//
//  TableViewCell.swift
//  FirebaseChat
//
//  Created by Jahongir Nematov on 4/11/18.
//  Copyright © 2018 Jahongir Nematov. All rights reserved.
//

import UIKit
import SnapKit

class UserCell: UITableViewCell {

    let topLabel : UILabel = {
        var label = UILabel()
        label.textColor = .amazingBrown
        return label
    }()
    
    let bottomLabel : UILabel = {
        var label = UILabel()
        label.textColor = .white
        return label
    }()
    
    let profileImageView : UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "profile")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        return imageView
    }()
    
    let timeLabel : UILabel = {
        var label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    let separatorView : UIView = {
        var view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style , reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(){
        
        self.backgroundColor = UIColor.amazingBlue
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(topLabel)
        contentView.addSubview(bottomLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(separatorView)
        
        profileImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).offset(10)
            make.top.equalTo(self.contentView).offset(10)
            make.bottom.equalTo(self.contentView).offset(-10)
            make.width.equalTo(80)
            
        }
        
        topLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView).offset(20)
            make.left.equalTo(self.profileImageView.snp.right).offset(20)
            
        }
        
        bottomLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.topLabel.snp.bottom).offset(20)
            make.left.equalTo(self.profileImageView.snp.right).offset(20)
            make.width.equalTo(180)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.contentView).offset(-20)
            make.right.equalTo(self.contentView).offset(-20)
        }
        
        separatorView.snp.makeConstraints { (make) in
            make.left.equalTo(self.topLabel)
            make.right.equalTo(self.timeLabel)
            make.height.equalTo(1)
            make.bottom.equalTo(self.contentView)
        }
    }
    
    
   

}
