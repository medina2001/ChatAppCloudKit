//
//  ChatViewController.swift
//  ChatProject
//
//  Created by Gabriel de Oliveira Maciel on 25/11/20.
//

import CloudKit
import UIKit

class ChatViewController: UIViewController {
    var msgs: [CKRecord] = []
    var usersByID: [String : CKRecord] = [:]
    @IBOutlet weak var msgTableView: UITableView!
    
    
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
            record.setValue(self.nickname, forKey: "nickname")
            
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
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        privateDatabase.add(operation)
    }
    
    
//    @IBAction func UpdateConsole(_ sender: Any) {
//        msgs.removeAll()
//        usersByID.removeAll()
//        let predicate = NSPredicate(value: true)
//               
//               let query = CKQuery(recordType: "Message", predicate: predicate)
//               
//               query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
//               
//               let operation = CKQueryOperation(query: query)
//        operation.recordFetchedBlock = {record in
//            
//            
//            
//                DispatchQueue.main.async {
//                    self.msgs.append(record)
//                    self.msgTableView.reloadData()
//                    let ref = record["nickname"] as!CKRecord.Reference
//                    if self.usersByID[ref.recordID.recordName] == nil{
//                        self.privateDatabase.fetch(withRecordID: ref.recordID, completionHandler: {userRecord,error in
//                            DispatchQueue.main.async {
//                                self .usersByID[ref.recordID.recordName] = userRecord
//                                self.msgTableView.reloadData()
//                            }
//                        })
//                    }
//                }
//    
//            }
//        operation.queryCompletionBlock = {cursor, error in
//            DispatchQueue.main.async {
//                
//            }
//            
//        }
//        privateDatabase.add(operation)
//        }
//    
//    
//}
//
//extension ChatViewController:UITableViewDelegate,UITableViewDataSource{
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return msgs.count
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 105
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = msgTableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
//        let msg = msgs[indexPath.row]
//        let df = DateFormatter()
//               df.dateFormat = "HH:mm dd/MM/yy"
//               cell.DataLabel.text = df.string(from: msg.creationDate!)
//               
//               cell.msgTextView.text = msg["text"]!
//               if let user = usersByID[(msg["tweeter"] as! CKRecord.Reference).recordID.recordName]{
//                   cell.UserNameLabel.text = user["name"]!
//               }
//               else{
//                cell.UserNameLabel.text = ""
//               }
//        return cell
//    }
    
    
}
