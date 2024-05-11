//
//  DetailsViewController.swift
//  Alişveriş Notum
//
//  Created by Feyzullah Durası on 27.04.2024.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    
    var selectProductName = ""
    var selectProductUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectProductName != "" {
            
            saveButton.isHidden = true
            
            if let uuidString = selectProductUUID?.uuidString {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let sonuclar = try context.fetch(fetchRequest)
                    
                    if sonuclar.count > 0 {
                        for sonuc in sonuclar as! [NSManagedObject] {
                            if let name = sonuc.value(forKey: "isim") as? String {
                                nameTextField.text = name
                            }
                            if let price = sonuc.value(forKey: "fiyat") as? Int {
                                priceTextField.text = String(price)
                            }
                            if let size = sonuc.value(forKey: "beden") as? String {
                                sizeTextField.text = size
                            }
                            if let imageData = sonuc.value(forKey: "gorsel") as? Data {
                                let image = UIImage(data: imageData)
                                imageView.image = image
                            }
                        }
                    }
                    
                }catch{
                    print("hata mesajı")
                }
                
            }
        } else {
            
            saveButton.isHidden = false
            //saveButton.isEnabled = false
            
            nameTextField.text = ""
            priceTextField.text = ""
            sizeTextField.text = ""
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(keyboardClose))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageSelect))
        imageView.addGestureRecognizer(imageGestureRecognizer)
    }
    
    @objc func imageSelect() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        //saveButton.isEnabled = true
        self.dismiss(animated: true)
    }
    
    @objc func keyboardClose() {
        view.endEditing(true)
    }
    
    @IBAction func SaveButtonClick(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let alisveris = NSEntityDescription.insertNewObject(forEntityName: "Alisveris", into: context)
        alisveris.setValue(nameTextField.text!, forKey: "isim")
        alisveris.setValue(sizeTextField.text!, forKey: "beden")
        
        if let  price = Int(priceTextField.text!) {
            alisveris.setValue(price, forKey: "fiyat")
        }
        
        alisveris.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.pngData()
        
        alisveris.setValue(data, forKey: "gorsel")
        
        do {
            try context.save()
            print("kayıt edildi.")
        }catch {
            print("hata mesajı!")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
