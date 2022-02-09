//
//  AboutViewController.swift
//  MyPokemon
//
//  Created by Ade Reskita on 08/02/22.
//

import UIKit
import CoreData

class AboutViewController: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var txtfieldNama: UITextField!
    @IBOutlet weak var txtfieldEmail: UITextField!
    @IBOutlet weak var txtfieldTtl: UITextField!
    @IBOutlet weak var btnEditProfile: UIButton!
    @IBOutlet weak var lbNama: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var lbTtl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        imgView.layer.cornerRadius = 10
        fetchData()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func fetchData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")
        request.fetchLimit = 1

        do {
            guard let results = try? context.fetch(request) else { return }
            for result in results {
                let profile = result as! Profile
                self.lbNama.text = profile.name
                self.lbEmail.text = profile.email
                self.lbTtl.text = profile.born
                        
                txtfieldNama.text = profile.name
                txtfieldEmail.text = profile.email
                txtfieldTtl.text = profile.born
                print("Fetch completed..")
                print(results)
            }
        } catch {
            print("Fetch Failed..")
        }
    }

    @IBAction func saveProfile(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")
        request.fetchLimit = 1
        do {
            guard let results = try? context.fetch(request) else { return }
                
            if (results).isEmpty {
                let entity = NSEntityDescription.entity(forEntityName: "Profile", in: context)
                let newProfile = Profile(entity: entity!, insertInto: context)
                newProfile.name = self.txtfieldNama.text
                newProfile.email = self.txtfieldEmail.text
                newProfile.born = self.txtfieldTtl.text
                    
                do {
                    print("context save success.")
                    try context.save()
                    self.lbNama.text = txtfieldNama.text
                    self.lbEmail.text = txtfieldEmail.text
                    self.lbTtl.text = txtfieldTtl.text

                } catch {
                    print("context save error.")
                }
            } else { // edit
                do {
                    guard let results = try? context.fetch(request) else { return }
                    for result in results {
                        let profile = result as! Profile
                        profile.name = txtfieldNama.text
                        profile.email = txtfieldEmail.text
                        profile.born = txtfieldTtl.text
                        try context.save()
                        lbNama.text = profile.name
                        lbEmail.text = profile.email
                        lbTtl.text = profile.born
                        print("context edit success..")
                    }
                } catch {
                    print("context edit error.")
                }
            } // end of edit
        } catch {
            print("context error.")
        }
    }
}
