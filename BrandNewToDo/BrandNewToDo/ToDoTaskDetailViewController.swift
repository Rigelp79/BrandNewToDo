//
//  ToDoTaskDetailViewController.swift
//  BrandNewToDo
//
//  Created by Rigel Preston on 12/23/16.
//  Copyright © 2016 Rigel Preston. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class ToDoTaskDetailViewController: UIViewController {
    
    @IBOutlet weak var taskTitleField: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    @IBOutlet weak var taskDoneSwitch: UISwitch!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var gestureRecognizer: UITapGestureRecognizer!
    
    var task = Task()
    let datePickerData = ToDoCatStore.shared.getCategories()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.minimumDate = Date().addingTimeInterval(1.0 * 60.0)
        self.categoryPicker.dataSource = self
        self.categoryPicker.delegate = self
        taskTitleField.text = task.title
        
        // Doesn't allow anything below current time
        if task.dueDate > datePicker.minimumDate! {
            datePicker.date = task.dueDate
        } else {
            datePicker.date = datePicker.minimumDate!
        }
        
        taskDoneSwitch.isOn = task.complete
        categoryPicker.selectRow(task.category, inComponent: 0, animated: true)
        
        if let image = task.image {
            imageView.image = image
            addGestureRecognizer()
        } else {
            imageView.isHidden = true
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        taskTitleField.autocapitalizationType = .sentences
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addGestureRecognizer() {
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewImage))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    
    func viewImage() {
        if let image = imageView.image {
            ToDoTaskStore.shared.selectedImage = image
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageNavController")
            present(viewController, animated: true, completion: nil)
        }
    }
    
    fileprivate func showPicker(_ type: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = type
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        task.title = taskTitleField.text!
        let selectedPickerRow = categoryPicker.selectedRow(inComponent: 0)
        task.category = selectedPickerRow
        task.dueDate = datePicker.date
        task.lastModified = Date()
        task.complete = taskDoneSwitch.isOn
        task.image = imageView.image
        
        if task.dueDate > Date() {
            let userNotify = UNMutableNotificationContent()
            userNotify.title = task.title
            userNotify.subtitle = ""
            userNotify.categoryIdentifier = "Alert"
            userNotify.sound = UNNotificationSound.default()
            userNotify.body = "The deadline for \(task.title) is coming up!"
            let notificationDate = task.dueDate.timeIntervalSinceNow
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notificationDate, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: userNotify, trigger: trigger)
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var shouldContinue = true
        if identifier == "saveTaskDetail" {
            shouldContinue = checkTextField()
            shouldContinue = checkDueDate()
        }
        return shouldContinue
    }
    
    func checkTextField() -> Bool {
        var textFieldNotEmpty = true
        taskTitleField.text != "" ? (textFieldNotEmpty = true) : (textFieldNotEmpty = false)
        if !textFieldNotEmpty {
            let alert = UIAlertController(title: "Error!", message: "Tasks need a name first!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        return textFieldNotEmpty
    }
    
    func checkDueDate() -> Bool {
        let dueDateUsable = datePicker.date.compare(Date()) == .orderedDescending
        if !dueDateUsable {
            let alert = UIAlertController(title: "Error!", message: "Try using a future date and time!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        return dueDateUsable
    }
    
    @IBAction func choosePhoto(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Add Photo", message: "Choose a photo source", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in self.showPicker(.camera) }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in self.showPicker(.photoLibrary) }))
        present(alert, animated: true, completion: nil)
    }
}

extension ToDoTaskDetailViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return datePickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return datePickerData[row]
    }
}

extension ToDoTaskDetailViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil) //close the image picker when the user clicks cancel
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            let maxSize: CGFloat = 512
            let scale = maxSize / image.size.width
            let newHeight = image.size.height * scale
            
            UIGraphicsBeginImageContext(CGSize(width: maxSize, height: newHeight))
            image.draw(in: CGRect(x: 0, y: 0, width: maxSize, height: newHeight))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            imageView.image = resizedImage
            
            imageView.isHidden = false
            
            if gestureRecognizer != nil {
                imageView.removeGestureRecognizer(gestureRecognizer)
            }
            
            addGestureRecognizer()
        }
    }
}

extension ToDoTaskDetailViewController: UNUserNotificationCenterDelegate {
    
}

