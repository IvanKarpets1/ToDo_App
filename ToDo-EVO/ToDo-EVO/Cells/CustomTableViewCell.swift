import Foundation
import UIKit

class CustomTableViewCell: UITableViewCell {
    var dateLabel: UILabel = {
        var lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.alpha = 0.5
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    var timeLabel: UILabel = {
        var lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.alpha = 0.5
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    var noteTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 13)
        tv.isEditable = false
        tv.isSelectable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isScrollEnabled = false
        tv.textContainerInset = UIEdgeInsets.zero
        tv.textContainer.lineFragmentPadding = 0
        return tv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        self.addSubview(noteTextView)
        self.addSubview(dateLabel)
        self.addSubview(timeLabel)
        setupConstraints()
        
    }
    
    func setupConstraints(){
       
        dateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        dateLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        
        
        noteTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 0).isActive = true
        noteTextView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        noteTextView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        noteTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
    
    }
    
  
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
