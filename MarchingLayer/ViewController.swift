//
//  ViewController.swift
//  MarchingLayer
//
//  Created by Cem Olcay on 12.11.2017.
//  Copyright © 2017 cemolcay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var marchingLayerReferanceView: UIView?
  let marchingLayer = MarchingLayer()

  override func viewDidLoad() {
    super.viewDidLoad()
    marchingLayerReferanceView?.layer.addSublayer(marchingLayer)
    marchingLayer.frame = marchingLayerReferanceView?.frame ?? .zero
    marchingLayer.animationDirection = .right
    marchingLayer.animationSpeed = 1
    marchingLayer.preferredSpriteSize = CGSize(width: 50, height: 50)
    marchingLayer.verticalSpriteSpacing = 8
    marchingLayer.horizontalSpriteSpacing = 8
    marchingLayer.preferredSpriteTintColor = .darkGray
    marchingLayer.sprites = [Int](1...15).flatMap({ UIImage(named: "sheet\($0)") })
    marchingLayer.startAnimation()
  }
}
