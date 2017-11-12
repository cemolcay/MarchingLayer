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
    marchingLayer.frame = view.frame
    view.layer.addSublayer(marchingLayer)
    marchingLayer.animationDirection = .up
    marchingLayer.animationSpeed = 1
    marchingLayer.preferredSpriteSize = CGSize(width: 30, height: 30)
    marchingLayer.verticalSpriteSpacing = 5
    marchingLayer.horizontalSpriteSpacing = 5
    marchingLayer.sprites = [Int](1...15).flatMap({ UIImage(named: "musicSheetSliced\($0)") })
    marchingLayer.startAnimation()
  }
}
