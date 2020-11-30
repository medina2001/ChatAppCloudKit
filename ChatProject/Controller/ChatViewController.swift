//
//  ChatViewController.swift
//  ChatProject
//
//  Created by Gabriel de Oliveira Maciel on 25/11/20.
//

import CloudKit
import UIKit

class ChatViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
    }
    
    let privateDatabase = CKContainer(identifier: "iCloud.ChatApp").privateCloudDatabase
    
    var nickname:String = ""
    
    @IBOutlet weak var UserName: UILabel!
    
    @IBAction func TweetBut(_ sender: Any) {
        UserName?.text = nickname
        escreverMensagem(nickname: nickname)
    }
    
    func escreverMensagem(nickname: String){
        let predicate = NSPredicate(format: "name == %@", nickname)
        
        let query = CKQuery(recordType: "ChatUser", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        //        var user: CKRecord? #Vou usar depois
        
        operation.recordFetchedBlock = { record in
            DispatchQueue.main.async {
                //                user = record
            }
        }
        
        let alert = UIAlertController(title: "Cambio,cambio", message: "Seja rápido soldado!", preferredStyle: .alert)
        alert.addTextField()
        
        let textField = alert.textFields![0] as UITextField
        
        let saveAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            let text = textField.text
            
            let record = CKRecord(recordType: "Message")
            record.setValue(text, forKey: "text")
            
            //            let reference = CKRecord.Reference(record: user!, action: .deleteSelf)
            self.privateDatabase.save(record){ (savedRecord, error) in
                DispatchQueue.main.async {
                    if error == nil{
                        let alert = UIAlertController(title: "Tweet", message: "Tweet enviado! Recarregue para atualizar.", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(alert,animated: true, completion: nil)
                    }else{
                        let alert = UIAlertController(title: "Erro", message: error!.localizedDescription, preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(alert,animated: true, completion: nil)
                    }
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        saveAction.isEnabled = false
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main){ (notification) in
            saveAction.isEnabled = textField.text != ""
        }
        textField.backgroundColor = UIColor.clear
        alert.view.addSubview(textField)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        privateDatabase.add(operation)
    }
    
}
