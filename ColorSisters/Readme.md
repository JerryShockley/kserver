
24 Nov 2014
Version 1.4, Build 4
* Added interface class, as a singleton, to didFinishLaunchingWithOptions
* Initial version of UIPageControl for "home" or launch page
* Added Image assets from Kokko, Inc (FFAppImages.zip)
* Updated projects LaunchScreen.xib.  (This is different from the spec's launch page).
* Fixed many layout issues due to Storyboards.  Still TODO

20 Nov 2014
Version 1.3, Build 3
* Turn off flash with .showsCameraControls = NO
* Added KokkoGetProductImages() with methods from email (Scott, 20 Nov 2014)


20 Nov 2014
Version 1.2, Build 2
* Same known issues as Build 1
* Changed extension to UIImage+Match.mm
* Deployment target 7.1


18 Nov 2014
Bundle Identifier - com.kokko.ColorSisters
Version 1.0, Build 1


Known Issues
* Unit test of Interface is not working, see ColorSisterTests/InterfaceTests.m
* InterfaceTests.m compiles, but debugger does not trip in Unit test
* LaunchScreen.xib - needs spec
* Getting started needs text - "Launch and Tutorial (page 4-5 of Nov 12 spec)"
* Matches page - Layout is crowded at top
* Share Page - needs wiring to web service


Fixed Issues
* Storyboards are universal, and is messing up layouts on iPod Touch & iPhone 5c devices and simulators
* First revision of Interface, See Interface/UIImage+Match.m
  * Interface is built as UIImage "category", which is basically an extension of UIImage
  * See UIImage+Match.h
  * findChart() and findFace() are methods, but in another iteration they should be propertys?!?
