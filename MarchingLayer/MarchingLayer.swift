//
//  MarchingLayer.swift
//  MarchingLayer
//
//  Created by Cem Olcay on 12.11.2017.
//  Copyright © 2017 cemolcay. All rights reserved.
//

import UIKit

extension UIImage {

  /// Applies tint color to template rendered images.
  ///
  /// - Parameters:
  ///   - tintColor: Color you want to apply.
  ///   - size: Optional new size. Leave it nil if you want to use original image size. Defaults nil.
  /// - Returns: Returns tint colored version of the image.
  public func tintColoredImage(tintColor: UIColor?) -> UIImage? {
    guard let tintColor = tintColor else { return self }
    var tintedImage: UIImage?
    let image = withRenderingMode(.alwaysTemplate)
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    tintColor.set()
    image.draw(in: CGRect(origin: .zero, size: size))
    tintedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return tintedImage ?? self
  }
}

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

  /// Initilize with a sprite image and optional preferred sprite size.
  ///
  /// - Parameters:
  ///   - sprite: Image reference of sprite.
  ///   - preferredSize: Optional preferred size for sprite. Defaults nil. Leave nil for using original image size.
  init(sprite: UIImage, preferredSize: CGSize? = nil) {
    self.size = preferredSize ?? sprite.size
    self.sprite = sprite
    super.init()
    // Setup sprite
    frame = CGRect(origin: .zero, size: self.size)
    contentsGravity = kCAGravityResizeAspect
    contentsScale = UIScreen.main.scale
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
  public var sprites = [UIImage]()
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
    return sprites[index].tintColoredImage(tintColor: preferredSpriteTintColor)
  }

  // MARK: Lifecycle

  deinit {
    stopAnimation()
    marchingSprites.forEach({ $0.removeFromSuperlayer() })
  }

  // MARK: Drawing

  public override var frame: CGRect {
    didSet {
      redraw()
    }
  }

  public override func layoutSublayers() {
    super.layoutSublayers()
    if marchingSprites.isEmpty {
      setupSprites()
    }
  }

  /// Redraws layer from top.
  public func redraw() {
    let animating = isAnimating
    stopAnimation()
    marchingSprites.forEach({ $0.removeFromSuperlayer() })
    marchingSprites = []
    layoutIfNeeded()
    if animating {
      startAnimation()
    }
  }


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
        preferredSize: preferredSpriteSize)
      marchingSprites.append(randomSprite)
      addSublayer(randomSprite)

      // Layout sprite.
      randomSprite.frame.origin = CGPoint(x: currentX, y: currentY)
      currentX += randomSprite.size.width + horizontalSpriteSpacing
      maxY = max(maxY, randomSprite.size.height)

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
        shouldRemove = sprite.frame.origin.y + (sprite.frame.height / 2) < 0
      case .down:
        sprite.frame.origin.y += animationSpeed
        shouldRemove = sprite.frame.origin.y + (sprite.frame.size.height / 2) > frame.size.height
      case .left:
        sprite.frame.origin.x -= animationSpeed
        shouldRemove = sprite.frame.origin.x + sprite.frame.size.width < 0
      case .right:
        sprite.frame.origin.x += animationSpeed
        shouldRemove = sprite.frame.origin.x > frame.size.width
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
        preferredSize: preferredSpriteSize)
      marchingSprites.append(randomSprite)
      addSublayer(randomSprite)

      // Layout sprite
      switch animationDirection {
      case .up:
        randomSprite.position.x = marchingSprites[index].position.x
        randomSprite.frame.origin.y = frame.size.height + verticalSpriteSpacing
      case .down:
        randomSprite.position.x = marchingSprites[index].position.x
        randomSprite.frame.origin.y = verticalSpriteSpacing
      case .left:
        randomSprite.position.y = marchingSprites[index].position.y
        randomSprite.frame.origin.x = frame.size.width + horizontalSpriteSpacing
      case .right:
        randomSprite.position.y = marchingSprites[index].position.y
        randomSprite.frame.origin.x = -horizontalSpriteSpacing
      }

      // Remove sprite
      marchingSprites.remove(at: index).removeFromSuperlayer()
      CATransaction.commit()
    }

    removingSprites.removeAll()
  }
}
