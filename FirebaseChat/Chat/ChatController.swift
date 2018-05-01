//
//  ChatController.swift
//  FirebaseChat
//
//  Created by Jahongir Nematov on 4/12/18.
//  Copyright © 2018 Jahongir Nematov. All rights reserved.
//

import UIKit
import Firebase
import SnapKit
import RxSwift
import Kingfisher
import SimpleImageViewer

class ChatController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var user : User? {
        didSet{
            navigationItem.title = user?.name
            self.observeMessages()
            guard let urlString = user?.profileImageUrl else  { return }
            let url = URL(string: urlString)
            profileImageView.kf.indicatorType = .activity
            profileImageView.kf.setImage(with: url)
            
        }
        
        
    }
    
    var messages : Variable<[Message]> = Variable([])
    
    let cellIdentifier = "cell"
    let disposeBag = DisposeBag()
    
    var keyboardHeight : CGFloat = 0
    var bottomConstraint : Constraint?

    let tableView : UITableView = {
        var tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 30
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .interactive
        tableView.alwaysBounceVertical = true
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        return tableView
    }()
    
    let profileImageView : UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "profile")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    
    lazy var sendTextField : UITextField = {
        var textField = UITextField()
        textField.placeholder = "Enter message... "
        textField.delegate = self
        textField.autocorrectionType = .no
        textField.tintColor = UIColor.amazingBlue
        return textField
    }()
    
    lazy var sendImageView : UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSendImageMessage))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    let sendButton : UIButton = {
        var button =  UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(UIColor.amazingBlue, for: .normal)
        button.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        return button
    }()
    
    let separatorView : UIView = {
        var view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    lazy var inputContainerView : UIView = {
        let bottomView = UIView()
        bottomView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50 )
        bottomView.backgroundColor = .white
        
        bottomView.addSubview(separatorView)
        bottomView.addSubview(sendTextField)
        bottomView.addSubview(sendButton)
        bottomView.addSubview(sendImageView)
        
        
        
        separatorView.snp.makeConstraints { (make) in
            make.bottom.equalTo(bottomView.snp.top)
            make.left.right.equalTo(bottomView)
            make.height.equalTo(0.5)
        }
        
        sendImageView.snp.makeConstraints({ (make) in
            make.left.top.equalTo(bottomView).offset(5)
            make.bottom.equalTo(bottomView).offset(-5)
            make.width.equalTo(40)
        })
        
        
        sendButton.snp.makeConstraints { (make) in
            make.right.top.bottom.equalTo(bottomView)
            make.width.equalTo(60)
        }
        
        sendTextField.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(bottomView)
            make.left.equalTo(sendImageView.snp.right).offset(10)
            make.right.equalTo(sendButton.snp.left)
        }
        
        return bottomView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    
        
        setupTableView()
        setupCellConfiguration()
        setupKeyboardObservers()
        setupProfileImageVIew()
        
        
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showImage(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showImage(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    private func setupTableView() {
        tableView.register(ChatCell.self, forCellReuseIdentifier: cellIdentifier)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.top.equalTo(self.view)
            bottomConstraint =  make.bottom.equalTo(self.view).constraint
        }
        
        tableView.delegate = self
        
    }
    
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid , let toId = user?.id  else { return }
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
                var message = Message()
                message.fromId = dictionary["fromId"] as? String
                message.text = dictionary["text"] as? String
                message.timestamp = dictionary["timestamp"] as? NSNumber
                message.toId = dictionary["toId"] as? String
                message.imageUrl = dictionary["imageUrl"] as? String
                message.imageWidth = dictionary["imageWidth"] as? NSNumber
                message.imageHeight = dictionary["imageHeight"] as? NSNumber
                
                self.messages.value.append(message)
                
                let indexPath = IndexPath(row: self.messages.value.count - 1 , section: 0)
                if indexPath.row > -1 {
                    self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                }
                
            }, withCancel: nil)
        }, withCancel: nil)
        
    }
    
    
    private func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow , object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        if messages.value.count > 0 {
            let indexPath = IndexPath(row: self.messages.value.count - 1 , section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }

    @objc func handleKeyboardWillShow(_ notification : Notification) {
        if let keyboardFrame : NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyboardHeight = keyboardRectangle.height

        }

        if let keyboardDuration  = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            self.updateKeyboardConstraint(duration: keyboardDuration, height: -self.keyboardHeight)
        }


    }

    private func updateKeyboardConstraint(duration : TimeInterval , height : CGFloat) {
        UIView.animate(withDuration: duration, animations: {
            self.tableView.snp.updateConstraints({ (make) in
                make.bottom.equalTo(self.view).offset(height)
            })
            self.view.layoutIfNeeded()
        })
    }
    
    private func setupCellConfiguration() {
        messages.asObservable()
            .bind(to: tableView
                .rx
                .items(cellIdentifier: cellIdentifier, cellType: ChatCell.self)) { row , message , cell in
                    
                    if let text = message.text {
                        cell.messageTextView.text = text
                    }
                    
                    
                    if message.fromId == Auth.auth().currentUser?.uid {
                        cell.bubbleView.backgroundColor = UIColor.amazingBlue
                        cell.leftMessageConstraint?.deactivate()
                        cell.rightMessageConstraint?.activate()
                    } else {
                        cell.bubbleView.backgroundColor = UIColor.amazingBrown
                        cell.rightMessageConstraint?.deactivate()
                        cell.leftMessageConstraint?.activate()
                    }
                    
                    if let messageImageUrl = message.imageUrl , let height = message.imageHeight?.floatValue , let width = message.imageWidth?.floatValue {
                        cell.setupImageMessage(imageUrl: messageImageUrl , height : height  , width : width)
                        cell.messageTextView.isHidden = true
                    } else {
                        cell.messageTextView.isHidden = false
                        cell.deleteImage()
                    }
                    
                    cell.chatController = self

            }.disposed(by: disposeBag)
    }
    
    
    
    @objc func handleSendMessage(){
        
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        if sendTextField.text != "" {
        
        guard let text = sendTextField.text else { return }
        
        guard let toId = user?.id , let fromId = Auth.auth().currentUser?.uid , let timeStamp : NSNumber = Int(Date().timeIntervalSince1970) as NSNumber! else { return }
        let values = ["text" : text , "toId" : toId , "fromId" : fromId , "timestamp": timeStamp] as [String : Any]
        
        childRef.updateChildValues(values) { (error, reference) in
            if error != nil {
                print(error!)
                return
            }
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId : 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId : 1])
        }
            
        }
        
        self.sendTextField.text = ""
    }
    
    
    func performZoomView(imageViewController : ImageViewerController) {
        self.present(imageViewController, animated: true)
    }
    

   

}

extension ChatController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage()
        self.sendTextField.resignFirstResponder()
        return true
    }
}

extension ChatController : UINavigationControllerDelegate , UIImagePickerControllerDelegate {
    
    @objc func handleSendImageMessage () {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.dismiss(animated: true, completion: nil)
        
        var selectedImage : UIImage?
        
        if let imageOriginal = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = imageOriginal
        } else if let imageEdited = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImage = imageEdited
        } else {
            return
        }
        
        
        if let image = selectedImage {
            uploadToFirabaseStorageImageMessage(image: image)
        }
    }
    
    func uploadToFirabaseStorageImageMessage(image : UIImage) {
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                if let imageMessageUrl = metadata?.downloadURL()?.absoluteString {
                    self.sendMessageWithImageUrl(imageUrl: imageMessageUrl, image: image)
                }
                
            })
        }
    }
    
    func sendMessageWithImageUrl(imageUrl : String , image : UIImage) {
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
            guard let toId = user?.id , let fromId = Auth.auth().currentUser?.uid , let timeStamp : NSNumber = Int(Date().timeIntervalSince1970) as NSNumber! else { return }
        let values = [ "toId" : toId , "fromId" : fromId , "timestamp": timeStamp , "imageUrl" : imageUrl , "imageWidth" : image.size.width , "imageHeight" : image.size.height ] as [String : Any]
            
            childRef.updateChildValues(values) { (error, reference) in
                if error != nil {
                    print(error!)
                    return
                }
                
                let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
                
                let messageId = childRef.key
                userMessagesRef.updateChildValues([messageId : 1])
                
                let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
                recipientUserMessagesRef.updateChildValues([messageId : 1])
            }
            
        
    }
    
}

extension ChatController {
    
    private struct Const {
        static let ImageSizeForLargeState: CGFloat = 40
        static let ImageRightMargin: CGFloat = 16
        static let ImageBottomMarginForLargeState: CGFloat = 12
        static let ImageBottomMarginForSmallState: CGFloat = 6
        static let ImageSizeForSmallState: CGFloat = 32
        static let NavBarHeightSmallState: CGFloat = 44
        static let NavBarHeightLargeState: CGFloat = 96.5
    }
    
    private func setupProfileImageVIew() {
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(profileImageView)
        
        profileImageView.layer.cornerRadius = Const.ImageSizeForLargeState / 2
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        profileImageView.snp.makeConstraints { (make) in
            make.right.equalTo(navigationBar).offset(-Const.ImageRightMargin)
            make.bottom.equalTo(navigationBar).offset(-Const.ImageBottomMarginForLargeState)
            make.height.equalTo(Const.ImageSizeForLargeState)
            make.width.equalTo(profileImageView.snp.height)
        }
    }
    
    func moveAndResizeImage(for height: CGFloat) {
        let coeff: CGFloat = {
            let delta = height - Const.NavBarHeightSmallState
            let heightDifferenceBetweenStates = (Const.NavBarHeightLargeState - Const.NavBarHeightSmallState)
            return delta / heightDifferenceBetweenStates
        }()
        
        let factor = Const.ImageSizeForSmallState / Const.ImageSizeForLargeState
        
        let scale: CGFloat = {
            let sizeAddendumFactor = coeff * (1.0 - factor)
            return min(1.0, sizeAddendumFactor + factor)
        }()
 
        let sizeDiff = Const.ImageSizeForLargeState * (1.0 - factor)
        let yTranslation: CGFloat = {
            let maxYTranslation = Const.ImageBottomMarginForLargeState - Const.ImageBottomMarginForSmallState + sizeDiff
            return max(0, min(maxYTranslation, (maxYTranslation - coeff * (Const.ImageBottomMarginForSmallState + sizeDiff))))
        }()
        
        let xTranslation = max(0, sizeDiff - coeff * sizeDiff)
        
        profileImageView.transform = CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: xTranslation, y: yTranslation)
    }
    
    private func showImage(_ show: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.profileImageView.alpha = show ? 1.0 : 0.0
        }
    }
    
    
   
}

extension ChatController : UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let height = navigationController?.navigationBar.frame.height else { return }
        moveAndResizeImage(for: height)
    }
    
}













