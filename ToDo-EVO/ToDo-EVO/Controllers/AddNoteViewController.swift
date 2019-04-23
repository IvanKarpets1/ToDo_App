import Foundation
import UIKit
import CoreData

class AddNoteViewController: UIViewController, UITextViewDelegate {
    
    
    var userInputTextView:UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "placeholder text here..."
        tv.textColor = .lightGray
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.textContainer.lineFragmentPadding = 0
        tv.isEditable = true
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        userInputTextView.delegate = self
        
        view.addSubview(userInputTextView)
        setupBar()
        setupLayout()
    }
    
    func setupBar(){
        navigationItem.title = "Add"
        let saveBarButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSaveNote))
        navigationItem.rightBarButtonItem = saveBarButton
    }
    
    func setupLayout(){
        userInputTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        userInputTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        userInputTextView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        userInputTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        userInputTextView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == "placeholder text here..." && textView.textColor == .lightGray)
        {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "placeholder text here..."
            textView.textColor = .lightGray
            userInputTextView.isEditable = false
        }
        userInputTextView.isEditable = true
    }
    
    
    
    @objc func handleSaveNote(){
        
        guard userInputTextView.text != "placeholder text here..." && userInputTextView.text != "" else {
            noticeUserAddNote()
            return
        }
        
        let date = Date()
        let currentDate = date.dateAsString()
        let currentTime = date.timeAsString()
        guard let text = userInputTextView.text else {
            return
        }
    
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }

        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let note = Note(context: managedContext)
        note.text = text
        note.date = currentDate
        note.time = currentTime
        
        do {
            try managedContext.save()
            ViewController().notes.append(note)
            noticeUserIfSaved()
            self.userInputTextView.text = ""
            self.textViewDidChange(self.userInputTextView)
            
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    func noticeUserAddNote(){
        let alert = UIAlertController(title: nil, message: "Please, add a note.", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func noticeUserIfSaved(){
        let alert = UIAlertController(title: nil, message: "Saved successfully.", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension Date {
    func dateAsString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        return dateFormatter.string(from: self)
    }
    
    func timeAsString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
}
