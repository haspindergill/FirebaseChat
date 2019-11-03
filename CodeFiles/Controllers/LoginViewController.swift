//
//  LoginViewController.swift
//  FirebaseDemo
//
//  Created by Haspinder on 03/08/16.
//  Copyright © 2016 Haspinder Singh. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    var ref : FIRAuth?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FIRAuth.auth()?.signInAnonymously(completion: {(user,error) in
      if error != nil {
        print("error : \(error?.localizedDescription)"); return }
      else{
        self.performSegue(withIdentifier: "MoveToChat", sender: user?.uid)
            }
        })    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let chatVc = segue.destination as! ChatViewController
        chatVc.senderId = sender as? String
        chatVc.senderDisplayName =  "Haspinder" //Hard coded for sample
    }
}




