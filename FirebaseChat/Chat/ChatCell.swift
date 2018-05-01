//
//  ChatCell.swift
//  FirebaseChat
//
//  Created by Jahongir Nematov on 4/13/18.
//  Copyright © 2018 Jahongir Nematov. All rights reserved.
//

import UIKit
import SnapKit
import SimpleImageViewer

class ChatCell: UITableViewCell {
    
    var chatController : ChatController?
    
    let messageTextView : UITextView = {
        var textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textColor = .white
        textView.backgroundColor = .clear
        return textView
    }()
    
    let bubbleView : UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.amazingBlue
        view.layer.cornerRadius = 15
        return view
    }()
    
    lazy var messageImageView : UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleZoom))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
   
    
    let whiteView : UIView = {
        var view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    var leftMessageConstraint : Constraint?
    var rightMessageConstraint : Constraint?
    var leftImageConstraint : Constraint?
    var rightImageConstraint : Constraint?
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style , reuseIdentifier: reuseIdentifier)
        
        setupView()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        contentView.addSubview(bubbleView)
        contentView.addSubview(messageTextView)
        contentView.addSubview(whiteView)
        bubbleView.addSubview(messageImageView)
        
        messageTextView.snp.makeConstraints { (make) in
            make.top.equalTo(self.whiteView.snp.bottom)
            rightMessageConstraint = make.right.equalTo(self.contentView).offset(-15).constraint
            leftMessageConstraint = make.left.equalTo(self.contentView).offset(15).constraint
            make.bottom.equalTo(self.contentView)
            make.width.lessThanOrEqualTo(250)
        }
        
        bubbleView.snp.makeConstraints { (make) in
            make.top.equalTo(messageTextView.snp.top)
            make.right.equalTo(messageTextView.snp.right).offset(5)
            make.bottom.equalTo(messageTextView.snp.bottom)
            make.left.equalTo(messageTextView.snp.left).offset(-5)
        }
        
        
        whiteView.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView)
            make.right.left.equalTo(self.contentView)
            make.height.equalTo(10)
        }
    }
    
    func setupImageMessage(imageUrl : String , height : Float , width : Float) {
        
        contentView.addSubview(messageImageView)
        
        messageImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.bubbleView)
            make.height.lessThanOrEqualTo(self.bubbleView.snp.width).dividedBy(2)            
            
        }
        
        let url = URL(string: imageUrl)
        self.messageImageView.kf.indicatorType = .activity
        self.messageImageView.kf.setImage(with: url)
        
        
    }
    
    @objc func handleZoom () {
        print("zoom")
        let configuration = ImageViewerConfiguration { (config) in
            config.imageView = messageImageView
        }
        let imageViewController = ImageViewerController(configuration: configuration)
        self.chatController?.performZoomView(imageViewController: imageViewController)
        
    }
    
    func deleteImage(){
        messageImageView.removeFromSuperview()
    }
    
    

}
