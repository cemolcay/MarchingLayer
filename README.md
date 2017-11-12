MarchingLayer
====

Randomly fills layer with sprites and move them in any direction and speed you want.

Demo
----

![alt tag](https://github.com/cemolcay/MarchingLayer/raw/master/demo.gif)

Requirements
----

* Swift 4.0+
* iOS 8.0+
* tvOS 9.0+

Install
----

```
pod 'MarchingLayer'
```

Usage
----

Create and add a `MarchingLayer` into your view.  
Set `sprites` property with images you want to show in layer.  
Set `animationDirection` to `up`, `down`, `left` or `right`.  
Set `animationSpeed` to change animation speed.  
Call `startAnimation()` to start, `stopAnimation()` to stop marching animation.