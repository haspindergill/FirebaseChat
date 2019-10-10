//
//  ChatViewController.swift
//  FirebaseDemo
//
//  Created by Haspinder on 03/08/16.
//  Copyright © 2016 Haspinder Singh. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController{

    var messages = [JSQMessage]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    let rootReference = FIRDatabase.database().reference(fromURL: "https://awesomeproject-48de4.firebaseio.com")
    var messageRef: FIRDatabaseReference!
    var usersTypingQuery: FIRDatabaseQuery!

    var userIsTypingRef: FIRDatabaseReference!
    
    
    
    fileprivate var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBubbles()
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        messageRef = rootReference.child("messages")
        // Do any additional setup after loading the view.
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    fileprivate func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory?.outgoingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleBlue())
        incomingBubbleImageView = factory?.incomingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleLightGray())
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        observeMessages()
        observeTyping()

    }

    
    fileprivate func observeTyping() {
        let typingIndicatorRef = rootReference.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqual(toValue: true)
        usersTypingQuery.observe(.value) { (data: FIRDataSnapshot!) in
            if data.childrenCount == 1 && self.isTyping {
                return
            }
        self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func addMessage(_ id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        messages.append(message!)
    }
    
    
    fileprivate func observeMessages() {
        let messagesQuery = messageRef.queryLimited(toLast: 25)
        messagesQuery.observe(.childAdded) { (snapshot: FIRDataSnapshot!) in
            let id = snapshot.value!["senderId"] as! String
            let text = snapshot.value!["text"] as! String
            self.addMessage(id, text: text)
            self.finishReceivingMessage()
        }
    }

}


extension ChatViewController {
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
            as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.white
        } else {
            cell.textView!.textColor = UIColor.black
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
}


extension ChatViewController{
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!,
                                     senderDisplayName: String!, date: Date!) {
        
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
            "text": text,
            "senderId": senderId
        ]
        itemRef.setValue(messageItem)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
        isTyping = false
    }
    
}


extension ChatViewController {
    override func textViewDidBeginEditing(_ textView: UITextView) {
        super.textViewDidBeginEditing(textView)
        inputToolbar.setNeedsLayout()
    }
    
    
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            self.view.endEditing(true)
            return false
        }
        return true
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = textView.text != ""
    }
    
    
}
