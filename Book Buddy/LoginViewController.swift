//
//  LoginViewController.swift
//  Book Buddy
//
//  Created by Melvin Lee on 2/9/17.
//  Copyright © 2017 Melvin Lee. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    var activityIndicator = UIActivityIndicatorView()
    var initialSpringVelocity = 50
    var springWithDamping = 3.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allows dismissal of keyboard on tap anywhere on screen besides the keyboard itself
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Labels
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    // Text Fields
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    // Button Outlets
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var registerButtonOutlet: UIButton!
    
    // Image views
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    // Test generate button
    @IBAction func generate(_ sender: UIButton) {
        qrCodeImageView.image = generateQR(usernameTextField.text!)
    }
    
    
    // Button Actions
    @IBAction func loginButtonAction(_ sender: UIButton) {
        
        // Check to see if all required fields are filled
        if usernameTextField.text == "" || passwordTextField.text == "" {
            displayAlert("Error in login form", "A username and password are required to log in.", "Let's fix it.")
        } else {
            PFUser.logInWithUsername(inBackground: usernameTextField.text!, password: passwordTextField.text!, block: { (user, error) in
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                if error != nil {
                    var displayErrorMessage = "Please try again later."
                    if let errorMessage = error as? NSError {
                        displayErrorMessage = errorMessage.userInfo["error"] as! String
                    }
                    self.displayAlert("Login Error", displayErrorMessage, "Ok")
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                } else {
                    print("Success! User is logged in.")
                    self.displayAlert("Success!", "\(self.usernameTextField.text!) has been logged in!", "Cool!")
                }
            })
        }
        
    }
    
    @IBAction func registerButtonAction(_ sender: UIButton) {
        // Start the activity spinner
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        
        // Check to see if all required fields are filled
        if usernameTextField.text == "" || passwordTextField.text == "" || emailTextField.text == "" {
            displayAlert("Error in registration form", "A username, password, and an email is needed for registration.", "Let's fix it")
        } else {
        
            let user = PFUser()
        
            user.username = usernameTextField.text
            user.password = passwordTextField.text
            user.email = emailTextField.text
            user.setValue(["test book"], forKey: "library")
        
            // Attempt to sign the user up
            user.signUpInBackground(block: { (success, error) in
            
                //Stop indicator
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            
                if error != nil {
                    var displayErrorMessage = "Please try again later."
                    if let errorMessage = error as? NSError {
                        displayErrorMessage = errorMessage.userInfo["error"] as! String
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.activityIndicator.stopAnimating()
                    }
                    self.displayAlert("Signup Error", displayErrorMessage, "Ok")
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.activityIndicator.stopAnimating()
                } else {
                    print("Success! User is signed up.")
                    self.displayAlert("Welcome!", "Account created for \(self.usernameTextField.text!)!", "Great!")
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.activityIndicator.stopAnimating()
                    self.qrCodeImageView.image = self.generateQR(self.usernameTextField.text!)
                }
            })
        }
        
    }
    
    //Causes the view (or one of its embedded text fields) to resign the first responder status and drop into background
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func displayAlert(_ title: String, _ message: String, _ confirmation: String){
        self.dismissKeyboard()
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: confirmation, style: .default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func beginningAnimations(){
        // Animate username label in from the left
        usernameLabel.center.x = usernameLabel.center.x - 500
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: CGFloat(springWithDamping), initialSpringVelocity: CGFloat(initialSpringVelocity), options: UIViewAnimationOptions.curveEaseIn, animations: ({
            self.usernameLabel.center.x = self.usernameLabel.center.x + 500
        }), completion: nil)
        
        // Animate password label in from the right
        passwordLabel.center.x = passwordLabel.center.x + 500
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: CGFloat(springWithDamping), initialSpringVelocity: CGFloat(initialSpringVelocity), options: UIViewAnimationOptions.curveEaseIn, animations: ({
            self.passwordLabel.center.x = self.passwordLabel.center.x - 500
        }), completion: nil)
    }
    
    
    func generateQR(_ string: String) -> UIImage? {
        
        let data = string.data(using: String.Encoding.ascii)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter?.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        
        let output = filter?.outputImage?.applying(transform)
        if output != nil {
            return UIImage(ciImage: output!)
        }
        return UIImage()
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
