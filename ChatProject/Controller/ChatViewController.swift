//
//  ChatViewController.swift
//  ChatProject
//
//  Created by Gabriel de Oliveira Maciel on 25/11/20.
//

import CloudKit
import UIKit

class ChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    var msgs: [CKRecord] = []
    var usersByID: [String : CKRecord] = [:]
    //    Protocolo da TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return msgs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath) as? TableViewCell else{
            fatalError("Can't dequeue tweet table view cell")
        }
        let mensagem = msgs[indexPath.row]
        
        let df = DateFormatter()
        df.dateFormat = "HH:mm dd/MM/yy"
        cell.dateLabel.text = df.string(from: mensagem.creationDate!)
        cell.msgText.text = mensagem["text"]!
        if let user = usersByID[(mensagem["nickname"] as! CKRecord.Reference).recordID.recordName]{
            cell.userName.text = user["name"]!
        }
        else{
            cell.userName.text = "Anônimo"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
    
    //    listas criadas para leitura do banco de dados
    
    
    @IBOutlet weak var TableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        Escondendo o Back Button
        self.navigationItem.hidesBackButton = true
        //        Instanciando o Delegate & DataSource
        TableView.delegate = self
        TableView.dataSource = self
    }
    
    //    Instanciando Container
    let publicDatabase = CKContainer(identifier: "iCloud.ChatApp").publicCloudDatabase
    
    //    Criando variável nickname para receber o nome do usuário
    var nickname:String = ""
    
    //    Função do botão de enviar mensagem
    @IBAction func enviarBtn(_ sender: Any) {
        escreverMensagem(nickname: nickname)
    }
    
    //    Função para escrever mensagem do usuário
    func escreverMensagem(nickname: String){
        //    Procura um record do tipo "name" na entidade (RecordType) "ChatUser" com o mesmo valor de "nickname"
        let predicate = NSPredicate(format: "name == %@", nickname)
        
        let query = CKQuery(recordType: "ChatUser", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        var user: CKRecord?
        
        operation.recordFetchedBlock = { record in
            DispatchQueue.main.async {
                user = record
            }
        }
        
        //        Campo para escrever mensagem em um AlertController
        let alert = UIAlertController(title: "Câmbio,câmbio", message: "Seja rápido soldado!!!", preferredStyle: .alert)
        alert.addTextField()
        
        let textField = alert.textFields![0] as UITextField
        
        //        Cria a ação de salvar no banco de dados do Alerta
        let saveAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            let text = textField.text
            
            //        Cria e seta o record para o tipo desejado: Message -> text && nickname
            let record = CKRecord(recordType: "Message")
            record.setValue(text, forKey: "text")
            //
            let reference = CKRecord.Reference(record: user!, action: .deleteSelf)
            record.setValue(reference, forKey: nickname)
            //        Salva o record no banco de dados de forma assíncrona com mensagens de sucesso e erro
            self.publicDatabase.save(record){ (savedRecord, error) in
                DispatchQueue.main.async {
                    if error == nil{
                        let alert = UIAlertController(title: "Afirmativo!", message: "Mensagem enviada com sucesso!", preferredStyle: .alert)
                        
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
        
        //        Cria função de cancelar a ação de salvar no banco de dados do Alerta
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        saveAction.isEnabled = false
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main){ (notification) in
            saveAction.isEnabled = textField.text != ""
        }
        
        //        Adiciona ações do AlertController
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        //        Adiciona operação no publicDatabase
        publicDatabase.add(operation)
        
    }
    
    @IBAction func UpdateConsole(_ sender: Any) {
        print("Entrou na função update")
        msgs.removeAll()
        usersByID.removeAll()
        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "Message", predicate: predicate)
        
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = {record in
            
            DispatchQueue.main.async {
                
                self.msgs.append(record)
                self.TableView.reloadData()
                
                let ref = record["nickname"] as! CKRecord.Reference
                //                let ref = CKRecord.Reference(recordID: record.recordID, action: .none)
                
                if self.usersByID[ref.recordID.recordName] == nil{
                    self.publicDatabase.fetch(withRecordID: ref.recordID, completionHandler: {userRecord,error in
                        DispatchQueue.main.async {
                            self.usersByID[ref.recordID.recordName] = userRecord
                            self.TableView.reloadData()
                        }
                    })
                }
            }
        }
        
        operation.queryCompletionBlock = {cursor, error in
            DispatchQueue.main.async {
                //                Terminar animação que indica o carregamento do BD...
            }
            
        }
        publicDatabase.add(operation)
        
    }
}
