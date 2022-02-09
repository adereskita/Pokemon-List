//
//  MoveTVCell.swift
//  MyPokemon
//
//  Created by Ade Reskita on 09/02/22.
//

import UIKit

class MoveTVCell: UITableViewCell {

    @IBOutlet weak var moveTitleLbl: UILabel!
    @IBOutlet weak var typeLbl: UIButton!
    @IBOutlet weak var moveDescLbl: UILabel!
        
    static let identifier = "MoveCell"
    
    var viewModel = ViewModel()

    static func nib() -> UINib {
        return UINib(nibName: "MoveCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setDataCellWith(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setCellView(withViewModel viewModels: Species) {
        moveTitleLbl.text = viewModels.name?.replacingOccurrences(of: "-", with: " ", options: .regularExpression).capitalized
        let url = viewModels.url!.dropFirst(34).dropLast(1)
        
//        self.viewModel.fetchMove(id: String(url))
//        typeLbl.setTitle(self.viewModel.pokemonMove?.type?.name, for: .normal)
//        moveDescLbl.text = self.viewModel.pokemonMove?.flavorTextEntries?.first?.flavorText
        
    }

}
