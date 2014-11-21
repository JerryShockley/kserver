
20 Nov
Version 1.0, Build 3
* Turn off flash with .showsCameraControls = NO
* Added KokkoGetProductImages() with methods from email (Scott, 20 Nov 2014)


20 Nov
Version 1.0, Build 2
* Same known issues as Build 1
* Changed extension to UIImage+Match.mm
* Deployment target 7.1


18 Nov 2014
Bundle Identifier - com.kokko.ColorSisters
Version 1.0, Build 1
Known Issues
* Storyboards are universal, and is messing up layouts on iPod Touch & iPhone 5c devices and simulators
* First revision of Interface, See Interface/UIImage+Match.m
  * Interface is built as UIImage "category", which is basically an extension of UIImage
  * See UIImage+Match.h
  * findChart() and findFace() are methods, but in another iteration they should be propertys?!?
* Unit test of Interface is not working, see ColorSisterTests/InterfaceTests.m
  * InterfaceTests.m compiles, but debugger does not trip in Unit test