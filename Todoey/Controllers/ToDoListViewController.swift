//
//  ToDoListViewController.swift
//  Todoey
//
//  Created by Michael Granberry on 7/24/19.
//  Copyright © 2019 MGG. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        tableView.separatorStyle = .none
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name
        
        guard let colourHex = selectedCategory?.colour else {fatalError() }
        
        updateNavBar(withHexCode: colourHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "1D9BF6")
        
    }
    
    //MARK: - Nav Bar Setup Methods
    
    func updateNavBar(withHexCode colourHexCode: String) {
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controler does not exist.")}
        guard let navBarColour = UIColor(hexString: colourHexCode) else {fatalError()}
        
        navBar.barTintColor = navBarColour
        
        navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
        
        searchBar.barTintColor = navBarColour
 
    }
    
    //MARK - Tableview Datasource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            
            
            print("version 1: \(CGFloat(indexPath.row / todoItems!.count))")
            
            print("version 2: \(CGFloat(indexPath.row) / CGFloat(todoItems!.count))")
            
            
            
             // Ternary operator ==>
             // value = condition ? valueIfTrue : valueIfFalse
             cell.accessoryType = item.done ? .checkmark : .none
            
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        
        }
        
        tableView.reloadData()
    
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
//MARK: - Data Manipulation Methods
    
    
//MARK - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
       
            if let currentCategory = self.selectedCategory {
                do {
                try self.realm.write {
                    let newItem = Item()
                    newItem.title = textField.text!
                    newItem.dateCreated = Date()
                    currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
 
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
 
//MARK - Model Manupulation Methods
    

    
    func loadItems() {

        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = todoItems?[indexPath.row] {
            
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
                
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }
    
}

//MARK: -  - Search bar methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
    }
 
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        if searchBar.text?.count == 0 {
           
            loadItems()
           
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }

    }
}
