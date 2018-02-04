//
//  LoginViewController.swift
//  ParseChat
//
//  Created by Jonathan Grider on 1/30/18.
//  Copyright © 2018 Jonathan Grider. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {
  
  let userExistsAlert = UIAlertController(title: "User Exists", message: "The username you have chosen already exists", preferredStyle: .alert)
  let invalidAlert = UIAlertController(title: "Invalid ", message: "The username or password was invalid. Please try again.", preferredStyle: .alert)
  
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupAlertControllers()
    
    usernameTextField.delegate = self
    passwordTextField.delegate = self
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func signUpPressed(_ sender: Any) {
    
    // Make sure username & password are filled out
    if !usernameTextField.hasText || !passwordTextField.hasText {
      present(invalidAlert, animated: true) {
        
      }
    } else {
      registerUser()
    }
    
  }
  
  
  @IBAction func loginPressed(_ sender: Any) {
    // Make sure username & password are filled out
    if !usernameTextField.hasText || !passwordTextField.hasText {
      present(invalidAlert, animated: true) {
        
      }
    } else {
      loginUser()
    }
  }
  
  func registerUser() {
    // initialize a user object
    let newUser = PFUser()
    
    // set user properties
    newUser.username = usernameTextField.text
    newUser.password = passwordTextField.text
    
    // call sign up function on the object
    newUser.signUpInBackground { (success: Bool, error: Error?) in
      if let error = error {
        print(error.localizedDescription)
        if String(describing: error.localizedDescription).contains("Account already exists for this username.") {
          print("This user already has an account!!")
          
          self.present(self.userExistsAlert, animated: true) {
            // optional code for what happens after the alert controller has finished presenting
          }
        }
        
      } else {
        print("User Registered successfully")
        self.performSegue(withIdentifier: "loginSegue", sender: nil)
      }
    }
  }
  
  func setupAlertControllers() {
    // Set up alert for pre-existing username
    let OKAction = UIAlertAction(title: "OK", style: .destructive) { (action) in
      
    }
    self.userExistsAlert.addAction(OKAction)
    self.invalidAlert.addAction(OKAction)
    
  }
  
  func loginUser() {
    
    let username = usernameTextField.text ?? ""
    let password = passwordTextField.text ?? ""
    
    PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) in
      if let error = error {
        print("User log in failed: \(error.localizedDescription)")
        self.present(self.invalidAlert, animated: true) {
          // optional code for what happens after the alert controller has finished presenting
        }
      } else {
        print("User logged in successfully")
        self.performSegue(withIdentifier: "loginSegue", sender: nil)
      }
    }
  }
  
  
  
  
}
