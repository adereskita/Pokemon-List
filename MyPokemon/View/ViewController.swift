//
//  ViewController.swift
//  MyPokémon
//
//  Created by Ade Reskita on 08/02/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collViewHome: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var viewModel = ViewModel()
    
    var loadingView: HomeCollectionReusableView?
    var isLoading = false
    var isSearching = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        SetupUI()
        viewModel.fetchPokemon(offset: viewModel.offset, limit: viewModel.limit)
        bindViewModelEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func SetupUI() {
        self.collViewHome.register(HomeCollectionViewCell.nib(), forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
        // MARK: - Loading View
        let loadingReusableView = UINib(nibName: "HomeCollectionReusableView", bundle: nil)
        self.collViewHome.register(loadingReusableView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: HomeCollectionReusableView.identifier)

        // MARK: - Keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        let layout = collViewHome.collectionViewLayout as! UICollectionViewFlowLayout
        layout.estimatedItemSize = .zero
                
        collViewHome.delegate = self
        collViewHome.dataSource = self
        searchBar.delegate = self
    }
    
    func bindViewModelEvent() {
        viewModel.reloadList = { [weak self] ()  in
            // UI chnages in main tread
            DispatchQueue.main.async {
                self?.collViewHome.reloadData()
            }
        }

        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error.localizedDescription)
            }
        }
        
        viewModel.errorMessage = { [weak self] (message)  in
            DispatchQueue.main.async {
                if !Connectivity.isConnectedToInternet {
                    let alert = UIAlertController(title: "Network Problem", message: "No network connection.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
                    print(message)
                    self?.loadingView?.activityIndicator.stopAnimating()
            }
        }
    }
    
    func loadMoreData() {
            if !self.isLoading && self.isSearching == false {
                self.isLoading = true
                    
                DispatchQueue.global().async {
                    // Fake background loading task 1 seconds
                    sleep(1)
                    // Download more data
                    self.viewModel.fetchPokemon(offset: self.viewModel.offset, limit: self.viewModel.limit)
                    self.bindViewModelEvent()
                    
                    DispatchQueue.main.async {                        
                        self.isLoading = false
                    }
                }
            } else {
                self.isLoading = true
                    
                DispatchQueue.global().async {
                    sleep(1)
                    self.viewModel.fetchSearchPokemon(type: self.viewModel.searchText)
                    self.bindViewModelEvent()
                    
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }
        }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
//        isSearching = false
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching == true {
            return viewModel.pokeResultSearch.count
        } else {
            return viewModel.pokeResult.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isSearching == true {
            let cell = collViewHome.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.identifier, for: indexPath) as! HomeCollectionViewCell
            let pokeSearchObj = viewModel.pokeResultSearch[indexPath.row]
            
            cell.setImageSearch(withViewModel: pokeSearchObj)
            return cell
        } else {
            let cell = collViewHome.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.identifier, for: indexPath) as! HomeCollectionViewCell
            let pokeObj = viewModel.pokeResult[indexPath.row]

            cell.setImage(withViewModel: pokeObj)
            return cell
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        if !isSearching {
            let pokeObj = viewModel.pokeResult[indexPath.row]
            
            let id = pokeObj.url!.dropFirst(34).dropLast(1)
            vc.id = String(id)
            vc.name = pokeObj.name!.capitalized
            vc.imgUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png"
            vc.url = pokeObj.url!
        } else {
            let pokeObj = viewModel.pokeResultSearch[indexPath.row]
            
            let id = pokeObj.pokemon!.url!.dropFirst(34).dropLast(1)
            vc.id = String(id)
            vc.name = pokeObj.pokemon!.name!.capitalized
            vc.imgUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png"
            vc.url = pokeObj.pokemon!.url!
        }
                            
        collectionView.deselectItem(at: indexPath, animated: true)
    //        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
        
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isSearching == true {
            let lastColl = viewModel.pokeResultSearch.count - 1
            if indexPath.row == lastColl && !self.isLoading {
//                self.viewModel.offset += 10
                self.viewModel.limit += 10
                loadMoreData()
            }
        } else {
            let lastColl = viewModel.pokeResult.count - 1
            if indexPath.row == lastColl && !self.isLoading {
//                self.viewModel.offset += 10
                self.viewModel.limit += 10
                loadMoreData()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
        
    // MARK: - Mengatur Layout Loading Cell

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.isLoading {
            return CGSize.zero
        } else {
            return CGSize(width: collectionView.bounds.size.width, height: 52)
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HomeCollectionReusableView.identifier, for: indexPath) as! HomeCollectionReusableView
            loadingView = aFooterView
            loadingView?.backgroundColor = UIColor.clear
            return aFooterView
        }
        return UICollectionReusableView()
    }
        
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.loadingView?.activityIndicator.startAnimating()
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.loadingView?.activityIndicator.stopAnimating()
        }
    }


}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            self.viewModel.offset = 0
            self.viewModel.offset = 0
            viewModel.pokeResult = []
            viewModel.pokeResultSearch = []
            viewModel.searchText = ""
            viewModel.fetchPokemon(offset: 0, limit: 10)
        } else {
            isSearching = true
        }
    }
        
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.collViewHome.reloadData()
        view.endEditing(true)
    }
        
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.pokeResult = []
        viewModel.searchText = searchBar.text!
        loadMoreData()
        self.collViewHome.reloadData()
//        bindViewModelEvent()
        view.endEditing(true)
    }
}
