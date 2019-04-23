import Foundation
import UIKit
import CoreData


class NoteDetailViewController: UIViewController {

    var appDelegate = AppDelegate()
    var managedContext: NSManagedObjectContext!
    var fetchRequest: NSFetchRequest<NSManagedObject>!
    
    var textView:UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isUserInteractionEnabled = false
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.backgroundColor = .white
        tv.textContainer.lineFragmentPadding = 0
        return tv
    }()
    
    var textFieldBeforeEdit = UITextField()
    
    var note = Note() {
        didSet{
            guard let text = note.text else{
                return
            }
            textView.text = text
        }
    }
    
    var saveNoteButton = UIBarButtonItem()
    var editNoteButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    
        view.addSubview(textView)
        setupCoreDataStuff()
        setupBar()
        setupLayout()
    }
    
    func setupBar(){
        navigationItem.title = "Detail"
        
        
        editNoteButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self
            , action: #selector(handleEditNote))
        
        saveNoteButton = UIBarButtonItem(barButtonSystemItem: .save, target: self
            , action: #selector(handleUpdateRecord))
        
        let shareNoteButton = UIBarButtonItem(barButtonSystemItem: .action, target: self
            , action: #selector(handleShareNote))
        
        saveNoteButton.isEnabled = false
        navigationItem.rightBarButtonItems = [shareNoteButton, editNoteButton, saveNoteButton]
        
    }
    
    func setupCoreDataStuff(){
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext =
            appDelegate.persistentContainer.viewContext
        fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
    }
    
    @objc func handleShareNote(){
        guard let text = textView.text else {
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func handleUpdateRecord(){
        
        textView.isUserInteractionEnabled = false
        guard textFieldBeforeEdit.text != textView.text && textFieldBeforeEdit.text != "" else {
            return
        }

        guard let textPredicate = textFieldBeforeEdit.text else{
           return
        }
        
         fetchRequest.predicate = NSPredicate(format: "text = %@", textPredicate)

        do {
            let note = try managedContext.fetch(fetchRequest)
            
            
            guard let objectUpdate = note[0] as NSManagedObject? else{
                return
            }
            
            objectUpdate.setValue(textView.text, forKey: "text")
            textFieldBeforeEdit.text = textView.text
            
            do {
                try managedContext.save()
                noticeUserIfSaved()
            } catch  {
                print(error)
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        saveNoteButton.isEnabled = false
        editNoteButton.isEnabled = true
    }
    
    func noticeUserIfSaved(){
        let alert = UIAlertController(title: nil, message: "Saved successfully.", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func handleEditNote(){
        textFieldBeforeEdit.text = textView.text
        textView.isUserInteractionEnabled = true
        saveNoteButton.isEnabled = true
        editNoteButton.isEnabled = false
        
    }
    
    func setupLayout(){
        textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        textView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        textView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
    }
    
}

