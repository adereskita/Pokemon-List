//
//  DetailViewController.swift
//  MyPokemon
//
//  Created by Ade Reskita on 08/02/22.
//

import UIKit
import SDWebImage
import CoreData

protocol DetailViewDelegate: AnyObject {
//    func didRecieveWebsite(website: String)
}

class DetailViewController: UIViewController {
    
    var id: String = ""
    var name: String = ""
    var imgUrl: String = ""
    var url: String = ""
    var row: Int = 1
    var isCatched = false
        
    var viewModel = ViewModel()
    var myPokemonListVC = MyPokemonListVC()
    weak var pokeListDelegate: MyPokemonDelegate?
    
    let pokeballFill = UIImage(named: "Catched")
    let pokeball = UIImage(named: "Pokeball")
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var moveView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var imgDetail: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var lbId: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbType: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var btnTryCatchPoke: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var moveTableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!

    override func viewWillAppear(_ animated: Bool) {
            self.moveTableView?.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        }
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "contentSize" {
                if let newValue = change?[.newKey] {
                    let newSize = newValue as! CGSize
//                    self.tableViewHeight.constant = newSize.height
                }
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        SetupTable()
        fetchDatas()
        bindViewModelEvent()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.moveTableView?.removeObserver(self, forKeyPath: "contentSize")
        pokeListDelegate?.viewWillAppears()
    }
    
    func fetchDatas() {
        viewModel.fetchDetail(id: self.id)
        viewModel.fetchMoves(id: self.id)
        viewModel.fetchSpecies(id: self.id)
    }
    
    func bindViewModelEvent() {
        
        viewModel.reloadMove = { [weak self] ()  in
            // UI chnages in main tread
            DispatchQueue.main.async {
                self!.moveTableView?.reloadData()
            }
        }
        
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error.localizedDescription)
            }
        }
        viewModel.didFinishFetch = {
            guard let flavorTextEntries = self.viewModel.pokeSpecies?.flavorTextEntries?.first else { return }
            self.lbDescription.text = flavorTextEntries.flavorText!.replacingOccurrences(of: "\n", with: " ", options: .regularExpression)
            self.lbType.text = self.viewModel.pokeDetail?.types?.first!.type?.name?.capitalized
        }
    }
        
    @IBAction func didTapSegment(segment: UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 {
            self.moveTableView.isHidden = true
        } else {
            self.moveTableView.isHidden = false
        }
    }
    
    func SetupTable() {
        self.moveTableView?.delegate = self
        self.moveTableView?.dataSource = self
        self.moveTableView?.separatorStyle = .none
    }
    
    func setupUI() {
        self.moveTableView?.isHidden = true
        
        guard let url = URL(string: self.imgUrl) else { return }
        self.imgDetail.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.imgDetail.sd_setImage(with: url,
                                   placeholderImage: UIImage(systemName: "photo"),
                                   options: [],
                                   completed: { (image, error, cacheType, url) in

            guard let img = image else { return }
            let colors = img.getColors()
            self.imgDetail.backgroundColor = colors?.background
//            self.lbType.textColor = colors?.primary
            self.lbType.backgroundColor = colors?.background
        })
        self.imgDetail.clipsToBounds = false
            
        self.imgDetail.layer.shadowColor = #colorLiteral(red: 0.4274509804, green: 0.5529411765, blue: 0.6784313725, alpha: 1)
        self.imgDetail.layer.shadowOpacity = 0.35
        imgDetail.layer.shadowOffset = CGSize(width: 0.4, height: 1.4)
        imgDetail.layer.shadowRadius = 10
        imgDetail.layer.cornerRadius = 30
//        imgDetail.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            
        self.bottomView.layer.cornerRadius = 20
//        self.bottomView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.bottomView.layer.shadowColor = #colorLiteral(red: 0.4274509804, green: 0.5529411765, blue: 0.6784313725, alpha: 1)
        self.bottomView.layer.shadowOpacity = 0.25
        self.bottomView.layer.shadowRadius = 10
            
        self.btnTryCatchPoke.layer.cornerRadius = 20
            
        self.stackView.layer.cornerRadius = 5
        self.backBtn.layer.cornerRadius = 10
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.backTapped(gesture:)))
        backBtn.addGestureRecognizer(tapGesture)
        backBtn.isUserInteractionEnabled = true
        self.backBtn.tintColor = .white

        self.lbName.text = self.name
        
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 3
        let ids = Int(self.id)
        self.lbId.text = formatter.string(from: ids! as NSNumber)
            
        favBtn.layer.cornerRadius = 10
        self.favBtn.layer.shadowColor = #colorLiteral(red: 0.4274509804, green: 0.5529411765, blue: 0.6784313725, alpha: 1)
        self.favBtn.layer.shadowOpacity = 0.25
        self.favBtn.layer.shadowRadius = 10
                
        setupButtonState()
    }
    
    func setupButtonState() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let predicate = NSPredicate(format: "pokeID == \(self.id)")

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "PokemonCatched")
        fetchRequest.predicate = predicate

         do {
             guard let results = try? context.fetch(fetchRequest) else { return }

             print(results)

             if results.isEmpty {
                 self.isCatched = false
                 favBtn.setImage(pokeball, for: .normal)
             } else {
                 self.isCatched = true
                 favBtn.setImage(pokeballFill, for: .normal)
             }
         }
    }
    
    func showAlert() {
        let defaultName = self.name
        let alert = UIAlertController(title: "You Caught a \(defaultName)!", message: "Try to give your pokemon a nickname", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { field in
            field.placeholder = defaultName
            field.returnKeyType = .done
            field.keyboardType = .default
        })
        
        alert.addAction(UIAlertAction(title: "Release", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [self] _ in
            guard let fields = alert.textFields, fields.count == 1 else {return}
            
            let nickname = fields[0]
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            let predicate = NSPredicate(format: "pokeID == \(self.id)")

            let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "PokemonCatched")
            fetchRequest.predicate = predicate
                   
            do {
                guard let results = try? context.fetch(fetchRequest) else { return }

                if results.isEmpty {
                    let entity = NSEntityDescription.entity(forEntityName: "PokemonCatched", in: context)
                    let newCatched = PokemonCatched(entity: entity!, insertInto: context)
                    newCatched.id = Int32(self.id)!
                    newCatched.pokeID = self.id
                    newCatched.type = self.lbType.text
                    
                    if nickname.text!.isEmpty {
                        nickname.text = defaultName
                    }
                    newCatched.name = nickname.text
                    newCatched.backgroundImage = self.imgUrl
                           
                    do {
                        print("save complete.")
                        try context.save()
                        myPokemonListVC.myPokemonList.append(newCatched)
                        self.isCatched = true
                        favBtn.setImage(pokeballFill, for: .normal)
                    } catch {
                        print("context save error.")
                    }
                }
            }
            self.showAlertSucceed()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertSucceed() {
        let alert = UIAlertController(title: "Pokemon Saved.", message: "Please check your pokémon list.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Discard", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertRelease() {
        let alert = UIAlertController(title: "Pokemon Released.", message: "Removed a pokémon on your list.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Discard", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertFail() {
        let alert = UIAlertController(title: "No Pokemon was Caught ..", message: "Don't let the pokemon run away. catch it again.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Discard", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func backTapped(gesture: UIGestureRecognizer) {
        pokeListDelegate?.viewWillAppears()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tryCatchPokemon(_ sender: Any) {
        let randomInt = Int.random(in: 0..<2) // 50% chance 0 - 1
        if self.isCatched == true {
            showAlertSucceed()
        } else {
            if randomInt == 0 {
                showAlert()
            } else {
                showAlertFail()
            }
        }
    }
    
    @IBAction func savePokemon(_ sender: Any) {
        if self.isCatched == true {
            favBtn.setImage(pokeballFill, for: .normal)
        } else {
            favBtn.setImage(pokeball, for: .normal)
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let predicate = NSPredicate(format: "pokeID == \(self.id)")

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "PokemonCatched")
        fetchRequest.predicate = predicate
               
        do {
            guard let results = try? context.fetch(fetchRequest) else { return }

            if results.isEmpty {
                let randomInt = Int.random(in: 0..<2) // 50% chance 0 - 1
                if randomInt == 0 {
                    showAlert()
                } else {
                    showAlertFail()
                }
            } else {
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

                if let result = try? context.fetch(fetchRequest) {
                    for object in result {
       //                        context.delete(object as! NSManagedObject)
                        try context.execute(batchDeleteRequest)
                        print("delete complete.")
                        favBtn.setImage(pokeball, for: .normal)
                        self.isCatched = false
                        showAlertRelease()
                    }
                }
            }
        } catch {
            print("Fetch Failed..")
        }
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.pokeMoves.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.moveTableView.dequeueReusableCell(withIdentifier: MoveTVCell.identifier, for: indexPath) as! MoveTVCell
        
        let moveObj = viewModel.pokeMoves[indexPath.row]
        
        cell.setCellView(withViewModel: moveObj.move!)
        cell.setDataCellWith(viewModel: self.viewModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

    }
}
