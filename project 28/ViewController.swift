//
//  ViewController.swift
//  project 28
//
//  Created by Kristoffer Eriksson on 2020-11-29.
//
import LocalAuthentication
import UIKit

class ViewController: UIViewController {

    @IBOutlet var secret: UITextView!
    var passWord : String = "password"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "nothing to see here"
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
        
        
    }

    @IBAction func authenticateTapped(_ sender: Any) {
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            let reason = "Identify Yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        // error
                        let ac = UIAlertController(title: "Authentication Failed", message: "You could not be verified, pls try again", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        ac.addAction(UIAlertAction(title: "password", style: .default, handler: self?.enterPassword))
                        self?.present(ac, animated: true)
                        
                    }
                }
                
            }
        } else {
            //no biometrics
            let ac = UIAlertController(title: "Biometry not available", message: "Your device does not have biometric notification", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
        //unlockSecretMessage()
    }
    func enterPassword(_ sender: UIAlertAction){
        KeychainWrapper.standard.set(passWord, forKey: "password")
        
        let ac = UIAlertController(title: "Enter password?", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "ok", style: .default) {
            [weak self] _ in
            guard let pass = ac.textFields?[0].text else {return}
            if pass == KeychainWrapper.standard.string(forKey: "password"){
                self?.unlockSecretMessage()
            }
            
        })
        ac.addAction(UIAlertAction(title: "cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func lockScreen(){
        
        title = "nothing to see here"
        secret.isHidden = true
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
        
        
    }
    
    @objc func adjustForKeyboard(notification: Notification){
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        
        let keyboardScreenEnd = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEnd, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    func unlockSecretMessage(){
        secret.isHidden = false
        title = "secret stuff"
        
//        if let text = KeychainWrapper.standard.string(forKey: "SecretMessage"){
//            secret.text = text
//        }
        secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
        
        if secret.isHidden == false {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "lock", style: .plain, target: self, action: #selector(lockScreen))
        }
        
    }
    
    @objc func saveSecretMessage(){
        guard secret.isHidden == false else {return}
        
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        secret.resignFirstResponder()
        secret.isHidden = true
        
        title = "nothing to see here"
    }
}

