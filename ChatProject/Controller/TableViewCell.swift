//
//  TableViewCell.swift
//  ChatProject
//
//  Created by Rafael Dias Gonçalves on 01/12/20.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var msgTextView: UITextView!
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var DataLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
