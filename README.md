# AECollapsableTableView
A subclass of UITableView that supports the ability to collapse or expand sections in a table view. 

This library is inspired by the another similar project AECollectionView.  The AECollapsableTableView handles all collapse and expand logic

AECollapsableTableView defined the toggle method for a spefic section, so that the developers can trigger the toggle action conventiently. The section can be expanded by tapping the button in the header view. You can check detail in the sample project.

Additionally,  here goes the features you can utilize:
> - Set initial collapsable status of all sections in Interface Builder
> - Collpase all sections
> - Expand all sections
> - Toggle a specific section
> - Check whether a specific section is expanded
> - Scroll to proper content offset after toggle a specific section

## Screenshot
![AECollapsableTableView](https://github.com/canicelebrate/AECollapsableTableView/blob/master/AECollapsableTableView.gif)

## Implementation
  Subclassed the UITableView and utilize methods:beginUpdate, endUpdate, insertRowsAtIndexPaths and deleteRowsAtIndexPaths to implement the collapse and expand behavor of the table view section.

## Setup
### Using [CocoaPods](http://cocoapods.org)
1. Add the pod `AECollapsableTableView` to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html).

  ```ruby
  pod 'AECollapsableTableView'
  ```

2. Run `pod install` from Terminal, then open your app's `.xcworkspace` file to launch Xcode.

3. Import the `AECollapsableTableView.h` umbrella header.
    * Objective-C: `#import "AECollapsableTableView.h"`


That's it - now go to write a cool APP with AECollapsableTableView!

## Usage
### Sample Code (Objective-C)
AECollapsableTableView wrapped the section collaps and expand actions. Let's take a quick look at an example,

Steps

1. In the storyboard, set the class of the table view in your view controller to AECollapsableTableView.

2. Add the tableview view outlet in your view controller by dragging the AECollapsableTableView instance as a outlet from the storyboard to your .h or .m file.

3. In the proper place of your own .m file(e.g. when tapping the header view of the section), invoke AECollapsableTableView's method toggleCollapsableSection:

Please check more detail information in the sample project in this repository.

```objective-c
[self.tableView toggleCollapsableSection:btn.tag];
```

4. Speficy which sections you want them collapsed initially
'''objective-c
self.tableView.initialCollapsedStatus = @{@1:@YES};
'''

## Meta
Originally designed & built by William ([@canicelebrate](https://github.com/canicelebrate)). Distributed with the MIT license.
