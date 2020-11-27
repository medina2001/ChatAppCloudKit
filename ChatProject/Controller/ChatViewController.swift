//
//  ChatViewController.swift
//  ChatProject
//
//  Created by Gabriel de Oliveira Maciel on 25/11/20.
//

import UIKit

class ChatViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
    }
    

    @IBAction func TweetBut(_ sender: Any) {
        let alert = UIAlertController(title: "Cambio,cambio", message: "Seja rápido soldado!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           self.present(alert,animated: true, completion: nil)
        alert.addTextField { (textField) in
            
        }
    }
    func escreverMensagem(){
        
    }
}



