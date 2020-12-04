//
//  ViewController.swift
//  ChatProject
//
//  Created by Gabriel de Oliveira Maciel on 24/11/20.
//

import CloudKit
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var UserNameText: UITextField!
    @IBOutlet weak var CadastrarButton: UIButton!
    
    var Username = ""
    
    @IBAction func Cadastrar(_ sender: Any) {
        if UserNameText.text == ""{
            let alert = UIAlertController(title: "Atenção", message: "Preencha o campo obrigatório acima com o seu nome!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in}))
            self.present(alert,animated: true, completion: nil)
        }else{
            Username = UserNameText.text ?? ""
            cadastrarUsuário(Username: Username)
        }
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
 
    let privateDatabase = CKContainer(identifier: "iCloud.ChatApp").privateCloudDatabase
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func cadastrarUsuário(Username: String){
        let predicate = NSPredicate(format: "name == %@", Username)
        
        let query = CKQuery(recordType: "ChatUser", predicate: predicate)
    
        let operation = CKQueryOperation(query: query)
        
        var existed = false
        operation.recordFetchedBlock = { record in
            DispatchQueue.main.async {
                existed = true
            }
        }
        
        operation.queryCompletionBlock = { cursor, error in
            DispatchQueue.main.async {      //Dar uma olhanda no pq é assincrono aqui
                if existed{
                    print("Bem Vindo %@", Username)
                    let alert = UIAlertController(title: "Atenção", message: "Prepare-se para ter uma conversa louca!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in}))
                    self.present(alert,animated: true, completion: nil)
                    self.performSegue(withIdentifier: "cadastroFinalizado", sender: nil )
                }else{
                    
                    print("Salvou no Banco de Dados!")
                    let record = CKRecord(recordType: "ChatUser")
                    record.setValue(Username, forKey: "name")
                    self.privateDatabase.save(record) { (savedRecord, error) in
                        DispatchQueue.main.async{
                            if error == nil{
                                self.performSegue(withIdentifier: "cadastroFinalizado", sender: nil )   
                                let alert = UIAlertController(title: "Ótimo! ;)", message: "O novo usuário, \(Username), foi criado com sucesso!", preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                                self.present(alert,animated: true, completion: nil)
                            }else{
                                self.shouldPerformSegue(withIdentifier: "cadastroFinalizado", sender: nil)
                                print("teste")
                                let alert = UIAlertController(title: "Eita", message: "Deu erro em alguma coisa...\n" + error!.localizedDescription, preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                                self.present(alert,animated: true, completion: nil)
                            }
                        }
                    }
                }
                
            }
        }
        privateDatabase.add(operation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ChatViewController
        {
            let vc = segue.destination as? ChatViewController
            vc?.nickname = Username
        }
    }
}
