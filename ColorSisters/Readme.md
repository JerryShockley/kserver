

18 Nov 2014
Bundle Identifier - com.kokko.ColorSiseters
Version 1.0, Build 1
Known Issues
* Storyboards are universal, and is messing up layouts on iPod Touch & iPhone 5c devices and simulators
* First revision of Interface, See Interface/UIImage+Match.m
  * Interface is built as UIImage "category", which is basically an extension of UIImage
  * See UIImage+Match.h
  * findChart() and findFace() are methods, but in another iteration they should be propertys?!?
* Unit test of Interface is not working, see ColorSisterTests/InterfaceTests.m
  * InterfaceTests.m compiles, but debugger does not trip in Unit test