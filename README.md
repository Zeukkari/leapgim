Leapgim
=======

Leap Motion gesture input mapper


Ubuntu 14.04 Installation
-------------------------

Current version is higly unstable and has been tested on node.js v0.10.40 only.

Node.js versions can be easily switched with the n package. In order to run leapgim you propably need to install it and switch node.js versions to whatever we're using for the moment.

Install n and switch node.js versions:

sudo npm install n -g
sudo n 0.10.40


Install dependencies:

sudo apt-get install g++ xorg-dev xutils xutils-dev libx11-dev libzmq3 libzmq3-dev

sudo npm install node-gyp -g

Install module dependencies:

( cd client; npm install . ) && ( cd server; npm install . )


Running
-------

Run development server: npm run server

Run development client: npm run client


Leapgim Development
===================

Developers:
- Andrushin Anton
- Petre Tudor
- Timo Aho

Featurelist
-----------

Map hand gestures to other types of input

- Mouse control
- Keyboard control
- Custom control (evoke scripts)
- A GUI for defining gestures


Feedback methods
----------------

A basic problem is that leap motion hand gestures provide no haptic feedback 
so we need to support it other ways

- Audio effects (mouse click, mouse down, button press etc)
- Visual feedback
-> Some kind of status window?
-> "Ghost hands" via webgl magic.. possibly?
- popup menus

Examples of use:
    -basic desktop usage: mouse movement, some limited keyboard support (arrow 
    keys, page up/down), close window, switch windows. switch desktops
    - media usage: playback controls etc
    - Propellerhead use cases:
    -> Home automation integration
-> Maybe a game control


Tech choices
------------

- Git & Github
- Coffeescript
- Node.js
- Node libraries
-> robot.js
-> somethig for desktop notifications (like growl, but growl does not support 
timers on notificications)
-> nw.js ?


Architecture 
------------

This is my idea of the basic architecture. The Frame Parser parses a leap 
motion frame into our own model, which contains information about hand 
positions so that it can be used in our gesture configuration.

This picture is still missing the Feedback Manager for sound, notifications 
and other stuff that provides the user feedback regarding their hand gestures.

```
------                ------------               -------------------
|Leapd| ------------> |Frame Parser|  ------->  | Leapgim model     |
 -----                ------------              | -> Gesture Config |
                                                | -> Current Frame  |
----------------------------------------------- | -> Previous Frame |
|         |                           |          -------------------
|         |                           |
|         |------------------         |
|         | Keyboard Manager |        |
|         -------------------         |
|            -> RobotJS calls         |----------------
|                                     | Mouse Manager |
|                                     -----------------
|----------------                       -> RobotJS calls
| Script Manager |
 ----------------      
    -> System calls
```


Leapgim Frame/Hand model
------------------------

The leapgim frame model contains human readable information about tracked 
hands. Properties supported in the legacy version at least included:

- Finger extended state for each finger

- Palm position: {x,y,z} - a 3-element object representing a point in 3d 
space. The sensor device is used as the point of origin, and the possible 
values are [0..1] for y and [-1..1] for x and z. Palm position is mainly used 
for mouse control.

- Palm direction: ["up", "down", "left", "right", "forward", "backward"]

- Grab strength: [0..1]

- Pinch strength: [0..1]

- Pinching finger: ["indexFinger", "middleFinger", "ringFinger", "pinkie"]

- Hand movement direction: {x,y,z} - a 3-element object representing a vector 
{x,y,z}


The legacy version of leapgim old held one model, but we could consider keeping the previous frame saved as well. This would allow as to configure gestures e.g. "hand movement changed from left to right after the previous moment".


Leapgim Gesture model
---------------------

Gesture model contained pretty much the same field as frame model, with some notable differences:
- For numeric values a {min, max} map object was used to provide acceptable parameters for each gesture.
- Timer attributes for gestures that were to be held a certain time perioid before triggering an action.
- Any value could basically be ommitted.


Mouse control tech notes
------------------------

The basic implementation is to query screen resolution and use it to map the x 
and y attributes of palm position into a point in screen. In addition, to make
mouse movement feasible several complementary techniques should be used.

Mouse Sensitivity
-----------------

Sensitivity is implemented as a multiplier to palm coordinates. A value of 1
indicates that mouse movement is mapped to the entire field of vision of the 
leap motion sensor. A value lesser than 1 makes mouse movement more accurate, 
but limits the mouse movement area to portion of the screen. A value greater 
than 1 makes it so that the mouse pointer reaches screen border before palm 
position reaches the border of sensor read area. 

A notable benefit for using a sensitivity value greater than one is that hand 
confidence levels drop in the edges. Forcing the user to remain in the middle 
of the device FOV greatly increases accuracy near screen borders.


Github
======
Main Repo: https://github.com/Zeukkari/leapgim

Track Main Repo from local fork: 
git remote add --track master leapgim git@github.com:Zeukkari/leapgim.git 

Pull changes from repo: 
git fetch leapgim
