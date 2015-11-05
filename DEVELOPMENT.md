# Leapgim future development

### Data Model draft

[https://github.com/Zeukkari/leapgim/wiki/Specification](https://github.com/Zeukkari/leapgim/wiki/Specification)

### Data model extension

*     Motions

*     Stuff from the legacy project

*     Gestures are currently not included I think

    * swipe and circle

*     See: Extend gesture support in:

    *  [https://github.com/Zeukkari/leapgim/wiki/Leapgim-TODO](https://github.com/Zeukkari/leapgim/wiki/Leapgim-TODO)

* pointables (= use a pen as a magic wand or something)

* multi step gestures optional audio notifications for different steps

**Multi sign gestures have not yet been tested!!**

Sign cancellation is problematic. For multi step gestures the previous sign should not deactive during a single frame between sign transitions. This is likely not possible for most simple multi sign gestures, and a solution needs to be implemented. One way to go about it is to just include a "deactivation delay" to the gesture controller and prevent sign deactivation during that time. A more elegant solutuion could also be used if we figure one out.

- The deactivation delay should be included per sign, and it needs to be implemented from scratch currently.

Configuration options for actions should greatly be extanded. We currently have around half a dozen actions implemented and half of those are for testing purposes only.

*     Mouse actions should include at least button up, down and click actions, left and right buttons should be supported. Mouse wheel should also be supported.

*     Keyboard actions are currently missing.

*     Script actions are currently missing. They're ultimately kinda a hack, but provide huge possibilities for creative applications.

*     It might be a great idea to include composite actions, which contain a list of actions to be completed in order. This would at least provide a handy workaround to keyboard actions supporting multiple modifier keys.

*     Additional mouse movement related actions should be added. For mouse freeze etc..

We need more feedback to the user. Audio notification code needs minor tinkering as the audio file names here and there aren't really well placed. We also need visual notifications to supplement.

Feedback is currently hard coded into actions. We should be able to provide configurable feedback for actions (which include teardowns) and signs. Maybe recipes but Im not sure now..

### GUI

GUI is effectively missing from the current master branch. GUI contains a few primary things to focus on:

*     Nw.js configuration options and other things that're particularry suitable to our application and improve the web experiemence with desktop level extended box of tricks.

*     React, Material-UI

*     General visual design

*     GUI design (based on use cases)

*     Audio feedback idea: use some kind of proximity indicator for when a user is near a touch zone or close to a certain pinch strength. Think of a rusty door hinge and initially produces a screeching noise and then clicks as the door is opened.

* Show connected server ip or hostname

* Let's use React and Material-UI..

    * [http://material-ui.com/#/get-started/examples](http://material-ui.com/#/get-started/examples)

    * [http://facebook.github.io/react/](http://facebook.github.io/react/)

    * [http://webpack.github.io/](http://webpack.github.io/)

    * https://github.com/callemall/material-ui/tree/master/examples

## Cross platform support

* Test on Windows

    * Apparently works according to Petre

* Test on OS X

    * Maybe we'll skip this

## Alpha release

The legacy version is hosted in npm and is currently linking to our repository. The version in npm is outdated and doesn't work, while our current version seems robust for basic mouse control. Let's do a release during the weekend cuz we're getting bad PR because of it.

