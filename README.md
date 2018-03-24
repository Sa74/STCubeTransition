# STCubeTransition
A custom view transition that provides transition between 2 different views with 3D cube rotate effect.

[![CI Status](http://img.shields.io/travis/Sa74/STCubeTransition.svg?style=flat)](https://travis-ci.org/Sa74/STCubeTransition)
[![Version](https://img.shields.io/cocoapods/v/STCubeTransition.svg?style=flat)](http://cocoapods.org/pods/STCubeTransition)
[![License](https://img.shields.io/cocoapods/l/STCubeTransition.svg?style=flat)](http://cocoapods.org/pods/STCubeTransition)
[![Platform](https://img.shields.io/cocoapods/p/STCubeTransition.svg?style=flat)](http://cocoapods.org/pods/STCubeTransition)

# Screenshot
![STCubeTransition](https://github.com/Sa74/STCubeTransition/blob/master/STCubeTransition/STCubeTransition/assets/STCubeTransition.gif)

## Installation

### Cocoapods
STCubeTransition is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'STCubeTransition'
```
You want to add pod 'STCubeTransition', '~> 1.0' similar to the following to your Podfile:

```
target 'MyApp' do
  pod 'STCubeTransition', '~> 1.0'
  use_frameworks!
end
```
Then run a pod install inside your terminal, or from CocoaPods.app.

Alternatively to give it a test run, run the command:

```
pod try STCubeTransition
```
### Manual
- Drag and drop `STCubeTransition.swift` class into your project in Xcode.
- Make sure you select all the targets required.

## Usage

It is much simpler than performing an UIView animation. 

If you use `Cocoapods`, First of all, import the framework:

```
import STCubeTransition
```

Then, init `CubeTransition` with delegate as follows,

```
let cubeTranstion:CubeTransition = CubeTransition()
cubeTranstion.delegate = self
```

next, perform cube transition between your views as follows,

```
cubeTranstion.translateView(faceView: self.faceView!,   // currently visible view
                            withView: subMenu!,         // hidden view that you want to display from this transition
                            toDirection: direction,     // any available CubeTransitionDirection
                            withDuration: 0.5)          // animation duration
```

Finally, implement the `CubeTransitionDelegate` optional method if you would like to perform any additional actions,

```
func animationDidFinishWithView(displayView: UIView) {
        // Do any additional work if required
    }
```

Here you go you are all setup for performing cool Cube Transition in you app 👍


## Author

[Sasi Moorthy](https://twitter.com/Sasi3726), 📧 msasi7274@gmail.com. Looking out for freelance work, if interested feel free to contact me.

## License

[STCubeTransition](https://cocoapods.org/pods/STCubeTransition) is available under the MIT license. See the LICENSE file for more info.
