//
//  MarchingLayer.swift
//  MarchingLayer
//
//  Created by Cem Olcay on 12.11.2017.
//  Copyright © 2017 cemolcay. All rights reserved.
//

import UIKit

/// `MarchingLayer` animation direction.
public enum MarchingLayerAnimationDirection {
  /// Animates sprites from bottom of the layer to top of the layer.
  case up
  /// Animates sprites from top of the layer to down of the layer.
  case down
  /// Animates sprites from right of the layer to left of the layer.
  case left
  /// Animates sprites from left of the layer to right of the layer.
  case right
}

/// Sprite item of `MarchingLayer`.
public class MarchingSpriteLayer: CALayer {
  /// Image of the sprite layer renders.
  var sprite: UIImage?
}

/// Randomly fills layer with sprites and move them in any direction and speed you want.
public class MarchingLayer: CALayer {
  /// Marching sprites. Layer randomly pops images from this array.
  public var sprites = [UIImage]()
  /// Direction of the marching animation.
  public var animationDirection = MarchingLayerAnimationDirection.up
  /// Speed of the marching animation.
  public var animationSpeed: CGFloat = 5.0
  /// Horizontal spacing between sprites.
  public var horizontalSpriteSpacing: CGFloat = 10.0
  /// Vertical spacing between sprites.
  public var verticalSpriteSpacing: CGFloat = 10.0
  /// Read-only property to check if layer is animating.
  public private(set) var isAnimating = false
  /// All sprite sublayers in layer.
  private var marchingSprites = [MarchingSpriteLayer]()
  /// Timer makes marching animation.
  private var marchingAnimationTimer: Timer?

  /// Returns a random image from `sprites` array. Returns nil if array is empty.
  private var randomImage: UIImage? {
    if sprites.count <= 0 {
      return nil
    }
    let index = Int(arc4random_uniform(UInt32(sprites.count)))
    return sprites[index]
  }

  // MARK: Init

  /// Default init function.
  public override init() {
    super.init()
    commonInit()
  }

  /// Default init function with layer reference.
  ///
  /// - Parameter layer: Layer object.
  public override init(layer: Any) {
    super.init(layer: layer)
    commonInit()
  }

  /// Default init function with coder.
  ///
  /// - Parameter aDecoder: NSCoder object.
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  /// Default init function after any public init function call.
  private func commonInit() {
    setupSprites()
  }

  // MARK: Sprites

  /// Pops the initial sprites into empty layer.
  private func setupSprites() {

  }

  // MARK: Animating

  /// Starts the marching animation.
  public func startAnimation() {
    isAnimating = true
    marchingAnimationTimer = Timer.scheduledTimer(
      timeInterval: TimeInterval(animationSpeed),
      target: self,
      selector: #selector(marchingAnimation),
      userInfo: nil,
      repeats: true)
  }

  /// Stops the marching animation.
  public func stopAnimation() {
    isAnimating = false
    marchingAnimationTimer?.invalidate()
    marchingAnimationTimer = nil
  }

  /// Marhing animation tick.
  @objc private func marchingAnimation() {
    for sprite in marchingSprites {
      switch animationDirection {
      case .up:
        sprite.frame.origin.y -= animationSpeed
        break
      case .down:
        break
      case .left:
        break
      case .right:
        break
      }
    }
  }
}
