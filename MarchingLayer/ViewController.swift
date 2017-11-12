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
    marchingLayer.frame = view.frame.insetBy(dx: 100, dy: 150)//.offsetBy(dx: 20, dy: 20)
    marchingLayer.borderColor = UIColor.red.cgColor
    marchingLayer.borderWidth = 1
    view.layer.addSublayer(marchingLayer)
    marchingLayer.animationDirection = .right // down up left
    marchingLayer.animationSpeed = 1
    marchingLayer.sprites = [Int](1...15).flatMap({ UIImage(named: "musicSheetSliced\($0)") })
    marchingLayer.startAnimation()
  }
}
