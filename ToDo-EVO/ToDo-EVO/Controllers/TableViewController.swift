import Foundation
import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    var appDelegate = AppDelegate()
    var managedContext: NSManagedObjectContext!
    var fetchRequest: NSFetchRequest<NSManagedObject>!
    
    var notes: [Note] = []
    var currentNotes: [Note] = []
    let cellid = "cellid"
    var searchController: UISearchController!
    var totalCountOfObjects = Int()
    
    var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupTableView()
        setupCoreDataStuff()
        setupGestureRecognizer()
        setupNavigationBarItems()
        setupSearchBar()
    }
    
    func setupTableView(){
        myTableView = UITableView()
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.translatesAutoresizingMaskIntoConstraints = false
        myTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: cellid)
        //constraints
        self.view.addSubview(myTableView)
        myTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        myTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        myTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        myTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        //auto-resizing cell height
        self.myTableView.rowHeight = UITableView.automaticDimension
        self.myTableView.estimatedRowHeight = 50
        
    }
    func setupCoreDataStuff(){
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext =
            appDelegate.persistentContainer.viewContext
        fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
    }
    
    func setupGestureRecognizer(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEdit(recognizer:)))
        myTableView.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
    }
    
    @objc func tapEdit(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizer.State.ended {
            let tapLocation = recognizer.location(in: self.myTableView)
            if let tapIndexPath = self.myTableView.indexPathForRow(at: tapLocation) {
                
                let viewController = NoteDetailViewController()
                viewController.note = currentNotes[tapIndexPath.row]
                navigationController?.pushViewController(viewController, animated: true)
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = currentNotes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellid, for: indexPath) as! CustomTableViewCell
        
        if let oldString = note.text {
            let newString = changeStringFormat(oldString: oldString)
            cell.noteTextView.text = newString
            cell.dateLabel.text = note.date
            cell.timeLabel.text = note.time
        }
        return cell
    }
    
    
    func changeStringFormat(oldString: String) -> String {
        if oldString.count > 100 {
            let index = oldString.index(oldString.startIndex, offsetBy: 99)
            return "\(String(oldString[...index]))..."
        }
        return oldString
    }
    
    
    func setupNavigationBarItems(){
        navigationItem.title = "My Notes"
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.5902182291, green: 0.1255885657, blue: 0.7004877855, alpha: 1)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.5902182291, green: 0.1255885657, blue: 0.7004877855, alpha: 1)
        
        let addNoteButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(handleAddNote))
        
        let sortImage = UIImage(named: "sort-image")
        let customButton = UIButton(type: .system)
        customButton.setImage(sortImage, for: .normal)
        customButton.addTarget(self, action: #selector(handleSortNotes), for: .touchUpInside)
        customButton.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        let rightSortButton = UIBarButtonItem(customView: customButton)
        
        navigationItem.rightBarButtonItems = [addNoteButton, rightSortButton]
        
    }

    @objc func handleSortNotes(){
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "From new to old", style: .default) { (action) in
            let sortTimeDescriptor = NSSortDescriptor(key: "time", ascending: false)
            let sortDateDescriptor = NSSortDescriptor(key: "date", ascending: false)
            self.fetchRequest.sortDescriptors = [sortDateDescriptor, sortTimeDescriptor]
            self.fetchSortedNotes()
            
        }
        
        let action2 = UIAlertAction(title: "From old to new", style: .default) { (action) in
            let sortTimeDescriptor = NSSortDescriptor(key: "time", ascending: true)
            let sortDateDescriptor = NSSortDescriptor(key: "date", ascending: true)
            self.fetchRequest.sortDescriptors = [sortDateDescriptor, sortTimeDescriptor]
            self.fetchSortedNotes()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("cancel")
        }
        
        sheet.addAction(action1)
        sheet.addAction(action2)
        sheet.addAction(cancelAction)
        present(sheet, animated: true, completion: nil)
    }
    
    
    func fetchSortedNotes(){
        do {
            self.notes = try self.managedContext.fetch(self.fetchRequest) as! [Note]
            self.currentNotes = self.notes
            self.myTableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @objc func setupSearchBar(){
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        myTableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard let textPredicate = searchBar.text else{
            return
        }
        
        if textPredicate != ""{
            currentNotes = notes.filter({ (note) -> Bool in
                return (note.value(forKey: "text") as! String).contains(textPredicate)
            })
            
        }else if textPredicate == "" {
            currentNotes = notes
        }
        myTableView.reloadData()
    }
    
    @objc func handleAddNote(){
        let viewController = AddNoteViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            managedContext.delete(currentNotes[indexPath.row] as NSManagedObject)
            self.notes.remove(at: indexPath.row)
            currentNotes = notes
            self.myTableView.deleteRows(at: [indexPath], with: .automatic)
            
            do {
                try managedContext.save()
                self.myTableView.reloadData()
            } catch {
                print("error : \(error)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do{
            self.totalCountOfObjects = try managedContext.count(for: fetchRequest)
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        do {
            notes = try managedContext.fetch(fetchRequest) as! [Note]
            currentNotes = notes
            self.myTableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
  
        
    
  
}

