//
//  ChatViewController.swift
//  MessageMe
//
//  Created by PuNeet on 29/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift

class ChatViewController: MessagesViewController {
    //MARK: Views
    let leftBarButtonView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        
    }()
    
    let titlelabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 5, y: 0, width: 140, height: 25))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        
        return title
    }()
    
    let subTitlelabel: UILabel = {
        let subTitle = UILabel(frame: CGRect(x: 5, y: 22, width: 180, height: 25))
        subTitle.textAlignment = .left
        subTitle.font = UIFont.systemFont(ofSize: 13 , weight: .medium)
        subTitle.adjustsFontSizeToFitWidth = true
        
        return subTitle
    }()
    
    //MARK: Vars
    private var chatId = ""
    private var recepientId = ""
    private var recepientName = ""
    
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser?.userName ?? "")
    let refershController = UIRefreshControl()
    let micButton = InputBarButtonItem()
    
    var mkMessages: [MKMessage] = []
    var allLocalMessages: Results<LocalMessage>!
    
    let realm = try! Realm()
    
    var displayingMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    
    var typingCounter = 0
    
    var gallery: GalleryController! 
    //Listeners
    
    var notificationToken: NotificationToken?
    
    //MARK: Initilizer
    init(chatId: String, recepientId: String, recepientName: String){
        super.init(nibName: nil, bundle: nil)
        
        self.chatId = chatId
        self.recepientId = recepientId
        self.recepientName = recepientName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK:  View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createTypingObserver()
        configurationMessageCollectionView()
        configureMessageInputBar()
        configureLeftbarButton()
        configureCustomTitle()
        updateTypingIndicator( true)
        loadChats()
        listenForNewChats()
        listenForReadStatusChange()
        
    }
    
    //MARK: Configuration
    
    private func configurationMessageCollectionView(){
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        messagesCollectionView.refreshControl = refershController
    }
    
    
    private func configureLeftbarButton(){
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPress))]
    }
    
    private func configureCustomTitle(){
        leftBarButtonView.addSubview(titlelabel)
        leftBarButtonView.addSubview(subTitlelabel)
        
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        
        titlelabel.text = recepientName
    }
    
    //MARK: Load chats
    
    private func loadChats(){
        let predicate = NSPredicate(format: "chatRoomId = %@", chatId)
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: kDATE, ascending: true)
        
        if allLocalMessages.isEmpty {
            checkForOldChats()
        }
        notificationToken = allLocalMessages.observe({ (changes: RealmCollectionChange) in
            
            switch changes{
            case .initial:
                self.insertMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: true)
            case .update(_,_,let insertions,_):
                for index in insertions{
                    self.insertMessage(self.allLocalMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom(animated: false)
                    
                }
            case .error(let error):
                print("error on insertion",error.localizedDescription)
            }
        })
    }
    
    //MARK: Insert messages
    
    private func listenForReadStatusChange(){
        FirebaseMessageListener.shared.ListenForReadStatusChange(User.currentId, chatId) { (updatedMessage) in
//            print("...........updated message",updatedMessage.message)
//            print("...........read status",updatedMessage.status)
            
            if updatedMessage.status != kSENT{
            self.updateMessage(updatedMessage)
            }
        }
    }
    private func listenForNewChats(){
        FirebaseMessageListener.shared.listenForNewChats(documentId: User.currentId, collectionId: chatId, lastMessageDate:  lastMessageDate())
    }
    
    private func checkForOldChats(){
        FirebaseMessageListener.shared.checkForOldChats(documentId: User.currentId, collectionId: chatId)
    }
    private func insertMessages(){
        maxMessageNumber = allLocalMessages.count - displayingMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGE
        
        if minMessageNumber < 0{
            minMessageNumber = 0
        }
        for i in minMessageNumber ..< maxMessageNumber {
            insertMessage(allLocalMessages[i])
        }
        
    }
    
    private func insertMessage(_ localMessage: LocalMessage){
        if localMessage.senderId != User.currentId{
        markMessageAsRead(localMessage)
        }
        let incomming = IncommingMessage(collectionView: self)
        self.mkMessages.append(incomming.createMessage(localMessage: localMessage)!)
        displayingMessagesCount += 1
    }
    
    //MARK: Actions
    func messageSend(text: String?, photo: UIImage?, video:Video?,audio: String?, location: String?, audioDuration: Float = 0.0){
        //        OutGoingMessage.sav
        OutGoingMessage.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio, location: location, memberIds: [User.currentId, recepientId])
    }
    
    @objc func backButtonPress(){
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        removeListener()
        self.navigationController?.popViewController(animated: true)
        //TODO: remove listener
        
    }
    
    private func actionAttachImages(){
        
        messageInputBar.inputTextView.resignFirstResponder()
        let optionMenue = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (alert) in
            self.showImageGallery(camera: true)
        }
        
        let shareMedia = UIAlertAction(title: "Library", style: .default) { (alert) in
            self.showImageGallery(camera: false)
        }
        
        let shareLocation = UIAlertAction(title: "Share location", style: .default) { (alert) in
            if let _ = LocationManager.shared.currentLocation{
                self.messageSend(text: nil, photo: nil, video: nil, audio: nil, location: kLOCATION)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            print("Cancel")
        }
        
        takePhotoOrVideo.setValue(UIImage.init(systemName: "camera"), forKey: "image")
        shareMedia.setValue(UIImage.init(systemName: "photo.fill"), forKey: "image")
        shareLocation.setValue(UIImage.init(systemName: "mappin.and.ellipse"), forKey: "image")
        
        optionMenue.addAction(takePhotoOrVideo)
        optionMenue.addAction(shareMedia)
        optionMenue.addAction(shareLocation)
        optionMenue.addAction(cancelAction)
        
        self.present(optionMenue, animated: true, completion: nil)
    }
    
    //MARK: Update typing indicator
    
    func createTypingObserver(){
        FirebaseTypingListener.shared.createTypingObserver(chatRoomId: chatId) { (isTyping) in
            DispatchQueue.main.async {
                self.updateTypingIndicator(isTyping)
            }
        }
    }
    
    func typingIndicatorUpdate(){
        typingCounter += 1
        print("Test............")
        FirebaseTypingListener.saveTypingCounter(typing: true, chatRoomId: chatId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            //Stop Tying
            self.typingCounterStop()
        }
    }
    
    func typingCounterStop(){
        typingCounter -= 1
        if typingCounter == 0{
            FirebaseTypingListener.saveTypingCounter(typing: false, chatRoomId: chatId)
        }
    }
    func updateTypingIndicator(_ show: Bool){
        subTitlelabel.text = show ? "typing..." : ""
    }
    
    //MARK: UIScrollView Delegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refershController.isRefreshing{
            if displayingMessagesCount < allLocalMessages.count{
                //               load earlier messages
                self.loadMoreMessages(maxNumber: maxMessageNumber, minMumber: minMessageNumber)
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            refershController.endRefreshing()
        }
    }
    
    private func loadMoreMessages(maxNumber: Int, minMumber: Int){
        maxMessageNumber = minMumber - 1
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGE
        
        if minMessageNumber < 0{
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber ... maxMessageNumber).reversed(){
            insertOlderMessage(allLocalMessages[i])
        }
    }
    
    private func markMessageAsRead(_ localMessage: LocalMessage){
        if localMessage.senderId != User.currentId && localMessage.status != kREAD{
            FirebaseMessageListener.shared.updateMessageInFirebase(localMessage, memberIds: [User.currentId, recepientId])
        }
    }
    
    private func insertOlderMessage(_ localMessage: LocalMessage){
        let incomming = IncommingMessage(collectionView: self)
        self.mkMessages.insert(incomming.createMessage(localMessage: localMessage)!, at: 0)
        
        //        append(incomming.createMessage(localMessage: localMessage)!)
        displayingMessagesCount += 1
    }
    private func configureMessageInputBar(){
        messageInputBar.delegate = self
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus",withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        attachButton.onTouchUpInside{ item in
            self.actionAttachImages()
        }
        micButton.image = UIImage(systemName: "mic.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        
        updateMicButtonStatus(true)
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
        // messageInputBar.setStackViewItems([micButton], forStack: .left, animated: false)
        //Add gesture recogniser
        
    }
    
    
    func updateMicButtonStatus(_ show: Bool){
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        }else{
            messageInputBar.setStackViewItems([messageInputBar.sendButton ], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
            
        }
    }
    
    //MARK: Update read message status
    
    private func updateMessage(_ localMessage: LocalMessage){
        
        for index in 0 ..< mkMessages.count{
            let tempMessage = mkMessages[index]
            if localMessage.id == tempMessage.messageId{
                mkMessages[index].status = localMessage.status
                mkMessages[index].readDate = localMessage.readDate
                RealmManager.shared.saveToRealm(localMessage)
                if mkMessages[index].status == kREAD{
                    self.messagesCollectionView.reloadData()
                }
            }
        }
    }
    
    //MARK: Helper
    
    private func removeListener(){
        FirebaseTypingListener.shared.removeTypingListener()
        FirebaseMessageListener.shared.removeListener()
    }
    
    private func  lastMessageDate() -> Date{
        let lastMessageData = allLocalMessages.last?.date ?? Date()
        
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageData) ?? lastMessageData
    }
    
    //MARK: Gallary
    
    private func showImageGallery(camera: Bool){
        gallery = GalleryController()
        gallery.delegate = self
        Config.tabsToShow = camera ? [.imageTab] : [.imageTab , .videoTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.VideoEditor.maximumDuration = 30
        
        
        self.present(gallery, animated: true, completion: nil)
    }
}


extension ChatViewController: GalleryControllerDelegate{
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0{
            images.first!.resolve { (image) in
                self.messageSend(text: nil, photo: image, video: nil, audio: nil, location: nil)
            }
        }
        
         controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        print("Selected video")
        self.messageSend(text: nil, photo: nil, video: video, audio: nil, location: nil)

         controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
         controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
