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
    var initialSpringVelocity = 35
    var springWithDamping = 3.0
    var whatsThis = false

    @IBOutlet weak var generateButtonOutlet: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateButtonOutlet.isEnabled = false
        generateButtonOutlet.alpha = 0
        
        // Check to see if a user is already logged in or not
        if PFUser.current() != nil {
            // Send the user to the main menu
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let view = storyboard.instantiateViewController(withIdentifier: "MainMenu")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = view
        }
        
        // Call the beginning animations method
        beginningAnimations()
        
        gotItButtonOutlet.isEnabled = false
        whatsThisButtonOutlet.isEnabled = false
        
        qrDescriptionTextField.isEditable = false
        
        
        // Allows dismissal of keyboard on tap anywhere on screen besides the keyboard itself
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var titleBarView: UIImageView!
    @IBOutlet weak var loginBox: UIImageView!
    @IBOutlet weak var qrBackgroundImage: UIImageView!
    @IBOutlet weak var bottomQRBackgroundImage: UIImageView!
    
    
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
    @IBOutlet weak var whatsThisButtonOutlet: UIButton!
    
    // Image views
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    // Text field for QR description
    @IBOutlet weak var qrDescriptionTextField: UITextView!
    
    // Button for when the user reads the qr description
    @IBOutlet weak var gotItButtonOutlet: UIButton!
    @IBAction func gotItButtonAction(_ sender: UIButton) {
        // Segue the user to the next screen
        
    }
    
    
    
    // Test generate button
    @IBAction func generate(_ sender: UIButton) {
        QRAnimations()
        qrCodeImageView.image = generateQR(usernameTextField.text!)
        qrDescriptionTextField.alpha = 1
        gotItButtonOutlet.alpha = 0.5
        self.whatsThisButtonOutlet.alpha = 1
        self.whatsThisButtonOutlet.isEnabled = true
        // Activate the button after 3 seconds
        let wait = DispatchTime.now() + 3.0
        DispatchQueue.main.asyncAfter(deadline: wait) {
            self.gotItButtonOutlet.alpha = 1
            self.gotItButtonOutlet.isEnabled = true
        }
    }
    
    
    // Button Actions
    @IBAction func whatsThisButtonAction(_ sender: UIButton) {
        if !whatsThis{
            qrDescriptionTextField.text = "A QR code is a machine-readable code consisting of an array of black and white squares, typically used for storing URLs or other information for reading by the camera on a smartphone."
            whatsThis = !whatsThis
            whatsThisButtonOutlet.setImage(#imageLiteral(resourceName: "GREAT"), for: [])
        } else {
            qrDescriptionTextField.text = "Pictured below is your very own QR Code! This was generated from your username. Whenever someone wants to add (link) you to their profile, just tell them to scan this, and it is done automatically!"
            whatsThis = !whatsThis
            whatsThisButtonOutlet.setImage(#imageLiteral(resourceName: "RegisterButton Copy"), for: [])
        }
    }
    
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
        // Clear the email text field because it is not needed
        emailTextField.text = ""
        
        // Check to see if all required fields are filled
        if usernameTextField.text == "" || passwordTextField.text == "" {
            if usernameTextField.text == "" {
                usernameTextField.backgroundColor = UIColor.red
            }
            
            if passwordTextField.text == "" {
                passwordTextField.backgroundColor = UIColor.red
            }
            
            
            displayAlert("Error in login form", "A username and password are required to log in.", "Let's fix it.")
        } else {
            
            // Start the activity spinner
            activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            PFUser.logInWithUsername(inBackground: usernameTextField.text!, password: passwordTextField.text!, block: { (user, error) in
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                if error != nil {
                    var displayErrorMessage = "Please try again later."
                    if let errorMessage = error as NSError? {
                        displayErrorMessage = errorMessage.userInfo["error"] as! String
                    }
                    self.displayAlert("Login Error", displayErrorMessage, "Ok")
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                } else {
                    print("Success! User is logged in.")
                    //self.displayAlert("Success!", "\(self.usernameTextField.text!) has been logged in!", "Cool!")
                    // Send the user to the main menu
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let view = storyboard.instantiateViewController(withIdentifier: "MainMenu")
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = view
                }
            })
        }
        
    }
    
    @IBAction func registerButtonAction(_ sender: UIButton) {
        self.dismissKeyboard()
        
        // Set the defualt image
        let defaultImage = PFFile(data: UIImageJPEGRepresentation(#imageLiteral(resourceName: "SadBook"), 1.0)!)
        
        
        // Check to see if all required fields are filled
        if usernameTextField.text == "" || passwordTextField.text == "" || emailTextField.text == "" {
            if usernameTextField.text == "" {
                usernameTextField.backgroundColor = UIColor.red
            }
            
            if passwordTextField.text == "" {
                passwordTextField.backgroundColor = UIColor.red
            }
            
            if emailTextField.text == "" {
                emailTextField.backgroundColor = UIColor.red
            }
            
            
            displayAlert("Error in registration form", "A username, password, and an email is needed for registration.", "Let's fix it")
        } else {
            QRAnimations()
            
            // Start the activity spinner
            activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
        
            let user = PFUser()
            
            user.username = usernameTextField.text
            user.password = passwordTextField.text
            user.email = emailTextField.text
            
            user.setValue(defaultImage, forKey: "profilePic")
            
            user.setValue(passwordTextField.text, forKey: "recoveryPassword")
            
            user.setValue([[]], forKey: "library")
            user.setValue([[]], forKey: "lentBooks")
            user.setValue([[]], forKey: "borrowedBooks")
            user.setValue([[]], forKey: "friends")
            user.setValue([[]], forKey: "friendRequests")
            user.setValue([[]], forKey: "wishList")
            user.setValue([[]], forKey: "deletedLibrary")
            user.setValue([[]], forKey: "requestedLibrary")
            user.setValue([[]], forKey: "receivedRequestsLibrary")
            
            
            user.setValue(0, forKey: "rating")
            user.setValue(0, forKey: "totalRating")
            user.setValue(0, forKey: "CurrentBookId")
            
            user.setValue(false, forKey: "didSaveFirstBook")
            user.setValue(false, forKey: "didSetProfilePic")
            user.setValue(false, forKey: "libraryPrivate")
            user.setValue(false, forKey: "lentFirstBook")
            user.setValue(false, forKey: "borrowedFirstBook")
            user.setValue(false, forKey: "didDeleteFirstBook")
            user.setValue(false, forKey: "didAddFirstFrend")
            user.setValue(false, forKey: "didSaveFirstWishListBook")
            user.setValue(false, forKey: "didRequestFirstBook")
            user.setValue(false, forKey: "didReceiveFirstRequest")
            
            
//            user.linkWithAuthType(inBackground: "User", authData: ["User": "ReceivedRequests"])
//            
//            print(user.isAuthenticated, " User auth")
            
        
            // Attempt to sign the user up
            user.signUpInBackground(block: { (success, error) in
            
                //Stop indicator
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            
                if error != nil {
                    var displayErrorMessage = "Please try again later."
                    if let errorMessage = error as NSError? {
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
                    self.qrDescriptionTextField.alpha = 1
                    self.gotItButtonOutlet.alpha = 0.5
                    self.whatsThisButtonOutlet.alpha = 1
                    self.whatsThisButtonOutlet.isEnabled = true
                    
                    //Disable all buttons and text fields
                    self.loginButtonOutlet.isEnabled = false
                    self.registerButtonOutlet.isEnabled = false
                    self.usernameTextField.isEnabled = false
                    self.passwordTextField.isEnabled = false
                    self.emailTextField.isEnabled = false
                    
                    // Activate the button after 3 seconds
                    let wait = DispatchTime.now() + 3.0
                    DispatchQueue.main.asyncAfter(deadline: wait) {
                        self.gotItButtonOutlet.alpha = 1
                        self.gotItButtonOutlet.isEnabled = true
                       
                    }
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
            self.usernameTextField.backgroundColor = UIColor.white
            self.passwordTextField.backgroundColor = UIColor.white
            self.emailTextField.backgroundColor = UIColor.white
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func beginningAnimations(){
        // Animate the title bar in from the top
        titleBarView.center.y = titleBarView.center.y - 1000
        UIView.animate(withDuration: 0.5, delay: 1.0, usingSpringWithDamping: CGFloat(springWithDamping), initialSpringVelocity: 30, options: UIViewAnimationOptions.curveEaseIn, animations: ({
            self.titleBarView.center.y = self.titleBarView.center.y + 1000
        }), completion: nil)
        
        // Animate the login box from the bottom
        loginBox.center.y = loginBox.center.y + 1000
        UIView.animate(withDuration: 0.5, delay: 1.4, usingSpringWithDamping: CGFloat(springWithDamping), initialSpringVelocity: 25, options: UIViewAnimationOptions.curveEaseIn, animations: ({
            self.loginBox.center.y = self.loginBox.center.y - 1000
        }), completion: nil)
        
        // Animate username label in from the left
        usernameLabel.center.x = usernameLabel.center.x - 500
        UIView.animate(withDuration: 0.5, delay: 1.8, usingSpringWithDamping: CGFloat(springWithDamping), initialSpringVelocity: CGFloat(initialSpringVelocity), options: UIViewAnimationOptions.curveEaseIn, animations: ({
            self.usernameLabel.center.x = self.usernameLabel.center.x + 500
        }), completion: nil)
        
        // Animate password label in from the right
        passwordLabel.center.x = passwordLabel.center.x + 500
        UIView.animate(withDuration: 0.5, delay: 2.0, usingSpringWithDamping: CGFloat(springWithDamping), initialSpringVelocity: CGFloat(initialSpringVelocity), options: UIViewAnimationOptions.curveEaseIn, animations: ({
            self.passwordLabel.center.x = self.passwordLabel.center.x - 500
        }), completion: nil)
        
        // Animate email label in from the left
        emailLabel.center.x = emailLabel.center.x - 500
        UIView.animate(withDuration: 0.5, delay: 2.2, usingSpringWithDamping: CGFloat(springWithDamping), initialSpringVelocity: CGFloat(initialSpringVelocity), options: UIViewAnimationOptions.curveEaseIn, animations: ({
            self.emailLabel.center.x = self.emailLabel.center.x + 500
        }), completion: nil)
        
        // Animate username text field in from the right
        usernameTextField.center.x = usernameTextField.center.x + 500
        UIView.animate(withDuration: 0.5, delay: 2.4, usingSpringWithDamping: CGFloat(springWithDamping), initialSpringVelocity: CGFloat(initialSpringVelocity), options: UIViewAnimationOptions.curveEaseIn, animations: ({
            self.usernameTextField.center.x = self.usernameTextField.center.x - 500
        }), completion: nil)
        
        // Animate password text field in from the left
        passwordTextField.center.x = passwordTextField.center.x - 500
        UIView.animate(withDuration: 0.5, delay: 2.6, usingSpringWithDamping: CGFloat(springWithDamping), initialSpringVelocity: CGFloat(initialSpringVelocity), options: UIViewAnimationOptions.curveEaseIn, animations: ({
            self.passwordTextField.center.x = self.passwordTextField.center.x + 500
        }), completion: nil)
        
        // Animate username text field in from the right
        emailTextField.center.x = emailTextField.center.x + 500
        UIView.animate(withDuration: 0.5, delay: 2.8, usingSpringWithDamping: CGFloat(springWithDamping), initialSpringVelocity: CGFloat(initialSpringVelocity), options: UIViewAnimationOptions.curveEaseIn, animations: ({
            self.emailTextField.center.x = self.emailTextField.center.x - 500
        }), completion: nil)
        
        // Animate the login and register buttons in from the bottom
        loginButtonOutlet.center.y = loginButtonOutlet.center.y + 1000
        registerButtonOutlet.center.y = registerButtonOutlet.center.y + 1000
        UIView.animate(withDuration: 0.5, delay: 3.4, usingSpringWithDamping: 25, initialSpringVelocity: 25, options: UIViewAnimationOptions.curveEaseIn, animations: ({
            self.loginButtonOutlet.center.y = self.loginButtonOutlet.center.y - 1000
            self.registerButtonOutlet.center.y = self.registerButtonOutlet.center.y - 1000
        }), completion: nil)
        
        qrBackgroundImage.center.x = qrBackgroundImage.center.x - 1000
        bottomQRBackgroundImage.center.y = bottomQRBackgroundImage.center.y + 1000
        whatsThisButtonOutlet.center.x = whatsThisButtonOutlet.center.x - 1000
        gotItButtonOutlet.center.x = gotItButtonOutlet.center.x + 1000
        qrDescriptionTextField.center.x = qrDescriptionTextField.center.x + 1000
        qrCodeImageView.center.y = qrCodeImageView.center.y + 1000
        
    }
    
    func QRAnimations(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: CGFloat(springWithDamping), initialSpringVelocity: 20, options: UIViewAnimationOptions.curveEaseIn, animations: ({
            self.qrBackgroundImage.center.x = self.qrBackgroundImage.center.x + 1000
            self.qrDescriptionTextField.center.x = self.qrDescriptionTextField.center.x - 1000
        }), completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: CGFloat(springWithDamping), initialSpringVelocity: 20, options: UIViewAnimationOptions.curveEaseIn, animations: ({
            self.bottomQRBackgroundImage.center.y = self.bottomQRBackgroundImage.center.y - 1000
            self.qrCodeImageView.center.y = self.qrCodeImageView.center.y - 1000
        }), completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 2.0, usingSpringWithDamping: CGFloat(springWithDamping), initialSpringVelocity: 20, options: UIViewAnimationOptions.curveEaseIn, animations: ({
            self.whatsThisButtonOutlet.center.x = self.whatsThisButtonOutlet.center.x + 1000
        }), completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 3.5, usingSpringWithDamping: CGFloat(springWithDamping), initialSpringVelocity: 20, options: UIViewAnimationOptions.curveEaseIn, animations: ({
            self.gotItButtonOutlet.center.x = self.gotItButtonOutlet.center.x - 1000
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
