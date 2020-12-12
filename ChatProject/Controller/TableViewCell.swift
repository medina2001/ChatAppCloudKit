//
//  TableViewCell.swift
//  ChatProject
//
//  Created by Rafael Dias Gonçalves on 01/12/20.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var msgText: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var background: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
