//
//  HomeCollectionReusableView.swift
//  GShop
//
//  Created by Ade Reskita on 08/02/22.
//

import UIKit

class HomeCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    static let identifier = "LoadingCell"

    static func nib() -> UINib {
        return UINib(nibName: "LoadingCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
