//
//  HomeCollectionViewCell.swift
//  GShop
//
//  Created by Ade Reskita on 08/02/22.
//

import UIKit
import SDWebImage
import UIImageColors

class HomeCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "HomeCollectionViewCell"

    static func nib() -> UINib {
        return UINib(nibName: "HomeCollectionViewCell", bundle: nil)
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cellActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbType: UILabel!
    @IBOutlet weak var lbId: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    var viewModels = ViewModel()
    let formatter = NumberFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
            
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            
        self.cellActivityIndicator.hidesWhenStopped = true
            
        cardView.layer.cornerRadius = 10
        cardView.layer.shadowColor = #colorLiteral(red: 0.4274509804, green: 0.5529411765, blue: 0.6784313725, alpha: 1)
        cardView.layer.shadowOpacity = 0.25
        cardView.layer.shadowOffset = CGSize(width: 0.4, height: 1.4)
        cardView.layer.shadowRadius = 10
        cardView.layer.shouldRasterize = true
    }
    
    func setImageSearch(withViewModel viewModel: Pokemon) {
        var imageUrlString: String?
        
        imageUrlString = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(viewModel.pokemon!.url!.dropFirst(34).dropLast(1)).png"
        
        self.lbTitle.text = viewModel.pokemon?.name?.capitalized
        
        formatter.minimumIntegerDigits = 3
        let id = Int(viewModel.pokemon!.url!.dropFirst(34).dropLast(1))
        self.lbId.text = formatter.string(from: id as! NSNumber)
        
        guard let imageURL = URL(string: imageUrlString!) else { return }
        self.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.imageView.sd_setImage(with: imageURL,
                                   placeholderImage: UIImage(systemName: "photo"),
                                   options: [],
                                   completed: { (image, error, cacheType, url) in
            
            guard let img = image else { return }
            img.getColors { colors in
                self.cardView.backgroundColor  = colors?.background
            }
        })
    }
    
    func setImage(withViewModel viewModel: Result) {
        var imageUrlString: String?
        
        imageUrlString = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(viewModel.url!.dropFirst(34).dropLast(1)).png"
        
//        self.lbType.text =
        self.lbTitle.text = viewModel.name?.capitalized
        
        formatter.minimumIntegerDigits = 3
        let id = Int(viewModel.url!.dropFirst(34).dropLast(1))
        self.lbId.text = formatter.string(from: id as! NSNumber)

        guard let imageURL = URL(string: imageUrlString!) else { return }
        self.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.imageView.sd_setImage(with: imageURL,
                                   placeholderImage: UIImage(systemName: "photo"),
                                   options: [],
                                   completed: { (image, error, cacheType, url) in
            
            guard let img = image else { return }
            img.getColors { colors in
                self.cardView.backgroundColor  = colors?.background
                self.lbTitle.textColor = colors?.primary
                self.lbId.textColor = colors?.detail            }
            // synchronus but lag
//            let colors = self.img!.getColors()
//            self.cardView.backgroundColor = colors?.background
        })
    }

}
