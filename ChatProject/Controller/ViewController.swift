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
 
    let publicDatabase = CKContainer(identifier: "iCloud.ChatApp").publicCloudDatabase
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CadastrarButton.layer.cornerRadius = 3
        UserNameText.delegate = self
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
                    print("Bem Vindo", Username)
                    self.performSegue(withIdentifier: "cadastroFinalizado", sender: nil )
                }else{
                    
                    print("Salvou no Banco de Dados!")
                    let record = CKRecord(recordType: "ChatUser")
                    record.setValue(Username, forKey: "name")
                    self.publicDatabase.save(record) { (savedRecord, error) in
                        DispatchQueue.main.async{
                            if error == nil{
                                self.performSegue(withIdentifier: "cadastroFinalizado", sender: nil )
                            }else{
                              self.shouldPerformSegue(withIdentifier: "cadastroFinalizado", sender: nil)
                                print("teste")
                            }
                        }
                    }
                }
                
            }
        }
        publicDatabase.add(operation)
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

extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
