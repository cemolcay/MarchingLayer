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
  /// Size of the sprite.
  var size: CGSize
  /// Set tint color of the sprites if you use template images.
  var tintColor: UIColor?

  /// Initilize with a sprite image and optional preferred sprite size.
  ///
  /// - Parameters:
  ///   - sprite: Image reference of sprite.
  ///   - preferredSize: Optional preferred size for sprite. Defaults nil. Leave nil for using original image size.
  init(sprite: UIImage, preferredSize: CGSize? = nil, tintColor: UIColor? = nil) {
    self.size = preferredSize ?? sprite.size
    self.sprite = sprite
    self.tintColor = tintColor
    super.init()
    // Setup sprite
    frame = CGRect(origin: .zero, size: self.size)
    contentsGravity = kCAGravityResizeAspect
    contents = sprite.cgImage
  }

  public override init(layer: Any) {
    self.size = .zero
    super.init(layer: layer)
  }

  public required init?(coder aDecoder: NSCoder) {
    self.size = .zero
    super.init(coder: aDecoder)
  }
}

/// Randomly fills layer with sprites and move them in any direction and speed you want.
public class MarchingLayer: CALayer {
  /// Marching sprites. Layer randomly pops images from this array.
  public var sprites = [UIImage]() { didSet{ setupSprites() }}
  /// Direction of the marching animation.
  public var animationDirection = MarchingLayerAnimationDirection.up
  /// Speed of the marching animation.
  public var animationSpeed: CGFloat = 0.1
  /// Horizontal spacing between sprites.
  public var horizontalSpriteSpacing: CGFloat = 10.0
  /// Vertical spacing between sprites.
  public var verticalSpriteSpacing: CGFloat = 10.0
  /// Set if you want to make all sprites size equal.
  /// Leave it nil if you want to use original sprite sizes. Defaults nil.
  public var preferredSpriteSize: CGSize?
  /// Set if you want to make all sprites same tint color. Leave it nil if you want to use original images.
  /// Setup images as template images if you want to use that feature. Defaults nil.
  public var preferredSpriteTintColor: UIColor?
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

  deinit {
    stopAnimation()
    marchingSprites.forEach({ $0.removeFromSuperlayer() })
  }

  // MARK: Sprites

  /// Pops the initial sprites into empty layer.
  private func setupSprites() {
    // Reset sublayers
    marchingSprites.forEach({ $0.removeFromSuperlayer() })
    marchingSprites = []

    var currentX: CGFloat = 0
    var currentY: CGFloat = 0
    var maxY: CGFloat = 0
    while currentY < frame.size.height {
      guard let randomImage = randomImage else { continue }
      let randomSprite = MarchingSpriteLayer(
        sprite: randomImage,
        preferredSize: preferredSpriteSize,
        tintColor: preferredSpriteTintColor)
      marchingSprites.append(randomSprite)
      addSublayer(randomSprite)

      // Layout sprite.
      randomSprite.frame.origin = CGPoint(x: currentX, y: currentY)
      currentX += randomSprite.size.width + horizontalSpriteSpacing
      maxY = max(maxY, randomSprite.size.height)

      // End loop if sprites laid out.
      if currentY > frame.size.height + maxY {
        break
      }

      // Move to new row.
      if currentX > frame.size.width {
        currentX = 0
        currentY += maxY + verticalSpriteSpacing
        maxY = 0
      }
    }
  }

  // MARK: Animating

  /// Starts the marching animation.
  public func startAnimation() {
    isAnimating = true
    marchingAnimationTimer = Timer.scheduledTimer(
      timeInterval: 1.0/60.0, // 60 FPS
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
    var removingSprites = [MarchingSpriteLayer]()
    for sprite in marchingSprites {
      var shouldRemove = false
      switch animationDirection {
      case .up:
        sprite.frame.origin.y -= animationSpeed
        shouldRemove = sprite.frame.origin.y + sprite.frame.size.height + (sprite.frame.size.height / 2) < 0
      case .down:
        sprite.frame.origin.y += animationSpeed
        shouldRemove = sprite.frame.origin.y - (sprite.frame.size.height / 2) > frame.size.height
      case .left:
        sprite.frame.origin.x -= animationSpeed
        shouldRemove = sprite.frame.origin.x + sprite.frame.size.width + (sprite.frame.size.width / 2)  < 0
      case .right:
        sprite.frame.origin.x += animationSpeed
        shouldRemove = sprite.frame.origin.x - sprite.frame.size.width > frame.size.width
      }

      if shouldRemove {
        removingSprites.append(sprite)
      }
    }

    for sprite in removingSprites {
      guard let index = marchingSprites.index(of: sprite),
        let randomImage = randomImage
        else { continue }

      CATransaction.begin()
      CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)

      // Spawn new sprite
      let randomSprite = MarchingSpriteLayer(
        sprite: randomImage,
        preferredSize: preferredSpriteSize,
        tintColor: preferredSpriteTintColor)
      marchingSprites.append(randomSprite)
      addSublayer(randomSprite)

      // Layout sprite
      switch animationDirection {
      case .up:
        randomSprite.position.x = marchingSprites[index].position.x
        randomSprite.frame.origin.y = frame.size.height
      case .down:
        randomSprite.position.x = marchingSprites[index].position.x
        randomSprite.frame.origin.y = -randomSprite.size.height
      case .left:
        randomSprite.position.y = marchingSprites[index].position.y
        randomSprite.frame.origin.x = frame.size.width + randomSprite.size.width
      case .right:
        randomSprite.position.y = marchingSprites[index].position.y
        randomSprite.frame.origin.x = -randomSprite.size.width
      }

      // Remove sprite
      marchingSprites.remove(at: index).removeFromSuperlayer()
      CATransaction.commit()
    }

    removingSprites.removeAll()
  }
}
