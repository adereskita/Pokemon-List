//
//  MyPokemonTableViewCell.swift
//  GShop
//
//  Created by Ade Reskita on 08/02/22.
//

import UIKit
import SDWebImage

class MyPokemonTableViewCell: UITableViewCell {
    @IBOutlet weak var pokeImageView: UIImageView!
    @IBOutlet weak var pokeNameLbl: UILabel!
    @IBOutlet weak var pokeTypeLbl: UILabel!
    @IBOutlet weak var pokeIdLbl: UILabel!
    
    var catched = PokemonCatched()
    var viewModel = ViewModel()
    let formatter = NumberFormatter()
            
    static let identifier = "MyPokemonTableViewCell"

    static func nib() -> UINib {
        return UINib(nibName: "MyPokemonTableViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setFavoriteData(withCoreData catched: PokemonCatched) {
        var imageUrlString: String?
        imageUrlString = catched.backgroundImage!

        formatter.minimumIntegerDigits = 3
        let ids = Int(catched.pokeID!)
        
        pokeNameLbl.text = catched.name
        pokeTypeLbl.text = catched.type
        pokeIdLbl.text = formatter.string(from: ids! as NSNumber)
        
        guard let imageURL = URL(string: imageUrlString!) else { return }
                
        self.pokeImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.pokeImageView.sd_setImage(with: imageURL)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
