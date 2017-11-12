//
//  ViewController.swift
//  MarchingLayer
//
//  Created by Cem Olcay on 12.11.2017.
//  Copyright © 2017 cemolcay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  let marchingLayer = MarchingLayer()

  override func viewDidLoad() {
    super.viewDidLoad()
    marchingLayer.frame = view.frame//.offsetBy(dx: 20, dy: 20)
//    marchingLayer.borderColor = UIColor.red.cgColor
//    marchingLayer.borderWidth = 1
    view.layer.addSublayer(marchingLayer)
    marchingLayer.sprites = [Int](1...15).flatMap({ UIImage(named: "musicSheetSliced\($0)") })
  }
}
