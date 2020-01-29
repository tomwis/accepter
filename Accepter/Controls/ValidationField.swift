//
//  ValidationField.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 21/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit

@IBDesignable
class ValidationField: UIView {
    
    var contentView: UIView?
    @IBOutlet weak var field: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        let view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        contentView = view
        
        errorLabel.text = nil
        errorLabel.textColor = UIColor.red
        errorLabel.font = UIFont.systemFont(ofSize: 14)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let views = nib.instantiate(withOwner: self, options: nil)
        let view = views.first as! UIView
        return view
    }
}
