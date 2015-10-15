Leapgim
=======

Leap Motion gesture input mapper


Ubuntu 14.04 Installation
-------------------------

Tested with: 

- node v4.1.2
- npm v2.14.4.
- Leap Motion SDK v2.3.1+31549

Install dependencies:

sudo apt-get install build-essential g++ xorg-dev xutils xutils-dev libx11-dev libzmq3 libzmq3-dev

Install leapgim bundle:

npm install .

Running
-------

Run server:

```
cd server
npm start
```

Run client:
```
cd client
npm start
```

Notes
-----

Node.js versions can be easily switched with the n package. In order to run leapgim you propably need to install it and switch node.js versions to whatever we're using for the moment.

Install n and switch node.js versions:

sudo npm install n -g
sudo n 2.14.4

Leapgim Development
===================

Developers:
- Petre Tudor
- Taija Mertanen
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
-> popup menus

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
-> nw.js
-> forever
-> zmq


Leapgim Frame Model
===================

- hands: Array
    - Hand Model
        - type: left|right
        - position: (x,y,z)
        - extendedFingers: Object
            - thumb: Bool
            - indexFinger: Bool
            - middleFinger: Bool
            - ringFinger: Bool
            - pinky: Bool
        - palmDirection: String
            - up|down|left|right|forward|backward
        - palmNormal: String
            - up|down|left|right|forward|backward
        - grabStrength
            - 0..1
        - pinch
            - strength:
                - 0...1
            - finger: String 
                - thumb|indexFinger|middleFinger|ringFinger|pinky

- gestures: Array
    - types: swipe, circle (possibly also: key tap and screen tap)
    - swipe
        - direction: String
            - up|down|left|right|forward|backward
    - circle
        - direction: String
            - up|down|left|right|forward|backward
        - progress: Float
            - number of rounds for the circle gestures


Leapgim Action Model
====================

Mouse Actions
-------------

- Movevement
    - Grab
    - Release
- Buttons
    - Click
    - Hold

Keyboard Actions
----------------

- Tap
    - support key combinations
- Hold

Script Evocation
----------------

- Evoke
- Start|Stop


Leapgim Control
---------------

Actions for redirecting leapgim data to certain client, or load a new recipe set in the current receiver. 


Leapgim Client Gestures
=======================

Define how Frame Model data is mapped to Action Model data.

Actions
-------

[template]
- action
- time (sleep after)
- feedback

Signs
-----

[template]
- sign
    - valid parameters for leapgim frame model
- time (in ms)

Recipes
-------

- Sign or signs
- Action
- (optional) tear down action


Leapgim Client Config
=====================

- socket (zmq notation)


Leapgim Server Config
=====================


- refresh interval
- minConfidence







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


Mouse control tech notes
------------------------

The basic implementation is to query screen resolution and use it to map the x 
and y attributes of palm position into a point in screen. In addition, to make
mouse movement feasible several complementary techniques should be used.


Github
======
Main Repo: https://github.com/Zeukkari/leapgim

Track Main Repo from local fork: 
git remote add --track master leapgim git@github.com:Zeukkari/leapgim.git 

Pull changes from repo: 
git fetch leapgim
