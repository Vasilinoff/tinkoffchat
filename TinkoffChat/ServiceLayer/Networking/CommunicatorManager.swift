//
//  CommunicatorManager.swift
//  TinkoffChat
//
//  Created by Vasily on 14.04.17.
//  Copyright © 2017 Vasily. All rights reserved.
//
import Foundation

protocol ContactManager {
    func send(message: String, to user: String)
    var activeContactName: String? { get }
    var isOnline: Bool? { get }
    
}

protocol ContactManagerDelegate: class {
    func becomeOnline()
    func becomeOffline()
}

class CommunicatorManager {

    var dataService = DataService()
    
    var communicator: Communicator
    
    var activeContactName: String?
    
    
    
    weak var activeContactDelegate: ContactManagerDelegate?

    init() {
        self.communicator = MultipeerCommunicator()
        self.communicator.delegate = self
    }
}

extension CommunicatorManager: ContactManager {
    var isOnline: Bool? {
        return (dataService.findOrCreateConversation(conversationId: activeContactName!)!.isOnline)
    }
    
    func send(message: String, to user: String) {
        communicator.sendMessage(string: message, to: user) { success, error in
            if success {
                let conversation = self.dataService.findOrCreateConversation(conversationId: self.activeContactName!)
                self.dataService.saveSendedMessage(conversation: conversation!, to: user, text: message)
            } else {
                print("\(String(describing: error))")
            }
        }
    }
}

extension CommunicatorManager: CommunicatorDelegate {
    func didFoundUser(userID: String, userName: String?) {
        
        let conversation = dataService.findOrCreateConversation(conversationId: userID)
        conversation?.isOnline = true
        let user = dataService.findOrCreateUser(userId: userID)
        user.isOnline = true
        
        dataService.saveFoundedConversation(conversationId:userID)

        
        if userID == activeContactName {
            activeContactDelegate?.becomeOnline()
        }
        

    }

    func didLostUser(userID: String) {
        let conversation = dataService.findOrCreateConversation(conversationId: userID)
        conversation?.isOnline = false
        
        let user = dataService.findOrCreateUser(userId: userID)
        user.isOnline = false
        
        if userID == activeContactName {
            activeContactDelegate?.becomeOffline()
        }
    }

    func failedToStartBrowsingForUsers(error: Error) {

    }

    func failedToStartAdvertising(error: Error) {

    }

    func didRecievedMessage(text: String, fromUser: String, toUser: String) {
        
        let conversation = dataService.findOrCreateConversation(conversationId: fromUser)
        
        dataService.saveReceivedMessage(conversation: conversation!, conversationId: fromUser, text: text)
        
    }
}
