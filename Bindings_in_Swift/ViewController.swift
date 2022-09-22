//
//  ViewController.swift
//  Bindings_in_Swift
//
//  Created by Jason Stelzel on 9/22/22.
//

import UIKit

class ViewController: UIViewController {
    var user = User(name: Observable("Jason Stelzel's Binding Demo"))

    @IBOutlet weak var username: BoundTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        username.bind(to: user.name)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
          self.user.name.value = "Type here..."
        }
    }
}

struct User {
    var name: Observable<String>
}

class Observable<ObservedType> {
    var valueChanged: ((ObservedType?) -> ())?
    private var _value: ObservedType?
    
    init(_ value: ObservedType) {
        _value = value
    }
    
    public var value: ObservedType? {
      get {
        return _value
      }
      set {
        _value = newValue
        valueChanged?(_value)
      }
    }
    
    func bindingChanged(to newValue: ObservedType) {
      _value = newValue
      print("Bound _value is now \(newValue)")
    }
}

class BoundTextField: UITextField {
    var changedClosure: (() -> ())?
    
    @objc func valueChanged() {
      changedClosure?()
    }
    
    func bind(to observable: Observable<String>) {
      addTarget(self, action: #selector(BoundTextField.valueChanged), for: .editingChanged)
      changedClosure = { [weak self] in
        observable.bindingChanged(to: self?.text ?? "")
    }
      observable.valueChanged = { [weak self] newValue in
        self?.text = newValue
    }
      // set our initial value, or an empty string if empty
      text = observable.value ?? ""
    }
}
