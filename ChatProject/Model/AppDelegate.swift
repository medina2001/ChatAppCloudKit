//
//  AppDelegate.swift
//  ChatProject
//
//  Created by Gabriel de Oliveira Maciel on 24/11/20.
//

import UIKit
import CoreData
import CloudKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().delegate = self

          // Request permission from user to send notification
          UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { authorized, error in
            if authorized {
              DispatchQueue.main.async(execute: {
                application.registerForRemoteNotifications()
              })
            }
          })
        return true
    }

        // nessa parte iremos usar o ID para definir para qual lugar a mensagem esta idno
        func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            
            // Ter um recodType criado no app
            // quando houver uma alteração o usuário será notificado
            
            // O predicado permite definir a condição da assinatura, por exemplo: só ser notificado da mudança se a notificação recém-criada começar com "A"
            // o TRUEPREDICATE significa que qualquer novo registro de Notificações criado será notificado
            let subscription = CKQuerySubscription(recordType: "Message", predicate: NSPredicate(format: "TRUEPREDICATE"), options: .firesOnRecordCreation)
            
            // serve pra deixar customizavel a notificação
            let info = CKSubscription.NotificationInfo()
            
            // isso usará o campo 'título' nas 'notificações' do tipo de registro como o título da notificação push
            info.titleLocalizationKey = "%1$@"
            info.titleLocalizationArgs = ["nickname"]
            
            // se você deseja usar vários campos combinados para o título da notificação push
            // info.titleLocalizationArgs = ["título", "subtítulo"]
            
            // isso usará o campo 'conteúdo' nas 'notificações' do tipo de registro como o conteúdo da notificação push
            info.alertLocalizationKey = "%1$@"
            info.alertLocalizationArgs = ["text"]
            
            
            info.shouldBadge = false //codigo q deixa o aviso vermelho tipo do wpp
            
           
            info.soundName = "default" // usar som
            
            subscription.notificationInfo = info
            
            // Salvar a inscriçao no container do app
            CKContainer(identifier: "iCloud.ChatApp").publicCloudDatabase.save(subscription, completionHandler: { subscription, error in
                if error == nil {
                    print("foi de boas")
                } else {
                    print("deu erro")
                }
            })
            
        }
    
    
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "ChatProject")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
extension AppDelegate: UNUserNotificationCenterDelegate{
    
  // This function will be called when the app receive notification
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    
    // show the notification alert (banner), and with sound
    completionHandler([.alert, .sound])
  }
  
  // This function will be called right after user tap on the notification
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    
    // tell the app that we have finished processing the user’s action (eg: tap on notification banner) / response
    completionHandler()
  }
}

