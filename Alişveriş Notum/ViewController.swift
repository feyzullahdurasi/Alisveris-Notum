//
//  ViewController.swift
//  Alişveriş Notum
//
//  Created by Feyzullah Durası on 27.04.2024.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    

    @IBOutlet weak var tableView: UITableView!
    
    var isimDizisi = [String]()
    var idDizisi = [UUID]()
    var selectName = ""
    var selectUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(eklemeButonuTiklandi))
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
    }
    
    @objc func getData() {
        
        isimDizisi.removeAll(keepingCapacity: false)
        idDizisi.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let sonuclar = try context.fetch(fetchRequest)
            
            if sonuclar.count > 0 {
                for sonuc in sonuclar as! [NSManagedObject] {
                    if let isim = sonuc.value(forKey: "isim") as? String {
                        isimDizisi.append(isim)
                    }
                    if let id = sonuc.value(forKey: "id") as? UUID {
                        idDizisi.append(id)
                    }
                }
            }
            
            tableView.reloadData()
            
        } catch {
            print("hata mesajı!")
        }
    }
    
    @objc func eklemeButonuTiklandi() {
        
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isimDizisi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = isimDizisi[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.selectProductName = selectName
            destinationVC.selectProductUUID = selectUUID
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectName = isimDizisi[indexPath.row]
        selectUUID = idDizisi[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
            let uuidString = idDizisi[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let sonuclar = try context.fetch(fetchRequest)
                if sonuclar.count > 0 {
                    for sonuc in sonuclar as! [NSManagedObject] {
                        if let id = sonuc.value(forKey: "id") as? UUID {
                            if id == idDizisi[indexPath.row] {
                                context.delete(sonuc)
                                isimDizisi.remove(at: indexPath.row)
                                idDizisi.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                do {
                                    try context.save()
                                } catch {
                                    print("hata")
                                }
                                
                                break
                            }
                        }
                    }
                }
            } catch {
                print("hata")
            }
            
        }
    }

}

