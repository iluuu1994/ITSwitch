ITSwitch
========

`ITSwitch` is a simple and lightweight replica of iOS 7 `UISwitch`.

![](./demo.png)

Usage
-----

Not much to it, simply set the custom class of a `NSView` to `ITSwitch` in Interface Builder.

You can create an IBAction and simply connect the two in Interface Builder.

Additionally, you can use those to properties:

```objc
@property (nonatomic, setter = setOn:) BOOL isOn;
@property (nonatomic, strong) NSColor *tintColor;
```

Tips
----

You may want to consider setting the width of the view to the golden ration * height. 

So for example:

```objc
height = 20;
width = height * 1.618;
```