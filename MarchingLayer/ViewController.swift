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
    marchingLayer.animationDirection = .left
    marchingLayer.animationSpeed = 1
    marchingLayer.preferredSpriteSize = CGSize(width: 30, height: 30)
    marchingLayer.verticalSpriteSpacing = 5
    marchingLayer.horizontalSpriteSpacing = 5
    marchingLayer.sprites = [Int](1...15).flatMap({ UIImage(named: "musicSheetSliced\($0)") })
    marchingLayer.startAnimation()
//    marchingLayer.transform = CATransform3DMakeRotation(CGFloat(-45.0 / 180.0 * M_PI), 0, 0, 1)
  }
}
