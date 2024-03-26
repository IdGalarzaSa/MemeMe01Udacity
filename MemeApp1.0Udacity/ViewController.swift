//
//  ViewController.swift
//  MemeApp1.0Udacity
//
//  Created by Ivan Galarza on 25/3/24.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    
    var keyboardIsShowing: Bool = false
    var isEditingTopField: Bool = false
    var imagePicked: UIImage? {
        didSet {
            if let _ = self.imagePickerView {
                shareButton.isEnabled = true
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        shareButton.isEnabled = false
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
        
        configTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func configTextFields() {
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
        
        topTextField.font = UIFont(name: "Impact", size: 20)
        bottomTextField.font = UIFont(name: "Impact", size: 20)
        
        topTextField.textColor = .white
        bottomTextField.textColor = .white
        
        view.bringSubviewToFront(topTextField)
        view.bringSubviewToFront(bottomTextField)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField.tag {
        case 0:
            topTextField.text = ""
            isEditingTopField = true
        case 1:
            bottomTextField.text = ""
            isEditingTopField = false
        default:
            break
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        resetKeyboardFlags()
        return true
    }
        
    // MARK: - Pick An Image
    
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 0:
            pickAnImage(sourceType: .camera)
        case 1:
            pickAnImage(sourceType: .photoLibrary)
        default:
            print("Error")
        }
    }
    
    func pickAnImage(sourceType: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        present(pickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.contentMode = .scaleAspectFit
            imagePickerView.image = selectedImage
            
            
            imagePicked = imagePickerView.image
        }
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    // MARK: - Share
    
    @IBAction func share(_ sender: Any) {
        
        guard let imagePicked = imagePicked else {
            return
        }
            
        let memedImage = createMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { [self]
            (activity, success, items, error) in
            if (success) {
                self.dismiss(animated: true, completion: nil)
                saveImage(originalImage: imagePicked, memedImage: memedImage)
            }
        }
        present(activityViewController, animated: true, completion: nil)

    }
    
    // MARK: - Methods
    func createMemedImage() -> UIImage {
        toggleToolbars(isHidden: true)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        toggleToolbars(isHidden: false)
        return memedImage
    }
    
    func toggleToolbars(isHidden: Bool) {
        topToolbar.isHidden = isHidden
        bottomToolbar.isHidden =  isHidden
    }
    
    
    func saveImage(originalImage: UIImage, memedImage: UIImage) {
        _ = Meme(topText: topTextField.text ?? "", bottomText: bottomTextField.text ?? "", originalImage: originalImage, memedImage: memedImage)
    }
    
    // MARK: - Keyboard
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if !keyboardIsShowing && !isEditingTopField {
            view.frame.origin.y -= getKeyboardHeight(notification)
            keyboardIsShowing = true
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        
        if keyboardIsShowing {
            view.frame.origin.y = 0
            resetKeyboardFlags()
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func resetKeyboardFlags() {
        keyboardIsShowing = false
        isEditingTopField = false
    }
    
}

