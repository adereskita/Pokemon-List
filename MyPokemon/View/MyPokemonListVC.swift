//
//  MyPokemonListVC.swift
//  MyPokemon
//
//  Created by Ade Reskita on 08/02/22.
//

import UIKit
import CoreData

protocol MyPokemonDelegate: AnyObject {
    func viewWillAppears()
}

class MyPokemonListVC: UITableViewController {
    
    var myPokemonList = [PokemonCatched]()
    weak var delegate: DetailViewDelegate?
    var initialLaod = true
    
    @IBOutlet weak var myPokeListTableView: UITableView!
        override func viewDidLoad() {
            super.viewDidLoad()
            fetchData()
            tableView.delegate = self
            tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func fetchData() {
        if initialLaod {
            initialLaod = false
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PokemonCatched")
                
            do {
                let results: NSArray = try context.fetch(request) as NSArray
                
                for result in results {
                    let favs = result as! PokemonCatched
                    myPokemonList.append(favs)
                    tableView.reloadData()
                }
            } catch {
                print("Fetch Failed..")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return myPokemonList.count
        }

        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = myPokeListTableView.dequeueReusableCell(withIdentifier: MyPokemonTableViewCell.identifier, for: indexPath) as! MyPokemonTableViewCell
            
            let pokeObj = myPokemonList[indexPath.row]
            
            cell.setFavoriteData(withCoreData: pokeObj)

            return cell
        }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            
        let pokeList = myPokemonList[indexPath.row]
            
        vc.id = pokeList.pokeID!
        vc.name = pokeList.name!
        vc.imgUrl = pokeList.backgroundImage!
                            
        tableView.deselectRow(at: indexPath, animated: true)
        vc.pokeListDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
}

extension MyPokemonListVC: MyPokemonDelegate {
    func viewWillAppears() {
        myPokemonList.removeAll()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PokemonCatched")

        do {
            let results: NSArray = try context.fetch(request) as NSArray

            for result in results {
                let catched = result as! PokemonCatched
                myPokemonList.append(catched)
                tableView.reloadData()
            }
        } catch {
            print("Fetch Failed..")
        }
    }

}
