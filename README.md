# Leap Motion gesture input mapper


Setup
=====

Windows 10 dependencies:
-----------------------
  * Nodejs and nvm: https://github.com/coreybutler/nvm-windows (download and install)
```
nvm install 4.1.2
nvm use 4.1.2
node -v
```
  * git: https://git-scm.com/download/win
  * node-gyp: `npm install -g node-gyp`
  * Visual Studio 2013
  * Python (v2.7.3 recommended, v3.x.x is not supported).


Ubuntu 14.04 dependencies:
..........................

Node.js versions can be easily switched with the n package. In order to run leapgim you propably need to install it and switch node.js versions to whatever we're using for the moment.

Install n and switch node.js versions:

```
sudo npm install n -g
sudo n 2.14.4
```

```
sudo apt-get install build-essential g++ xorg-dev xutils xutils-dev libx11-dev libzmq3 libzmq3-dev
```

Install
-------

```
npm install git+https://git@github.com/zeukkari/leapgim.git
```

Running
-------

```
npm start
```


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
