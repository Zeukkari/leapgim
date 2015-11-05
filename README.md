# Leap Motion gesture input mapper

Leapgim Client
==============

Recipes
-------

Recipes are how signs are translated into actions. The term is borrowed from IFTTT (https://ifttt.com/).

```

         ----------
signs -> | recipe | -> actions
         ----------

```

Action Types
------------

Mouse buttons:
- Mouse button down
- Mouse button up
- Mouse button click
- Mouse button double click
- Mouse scroll

Mouse movement:
- Move
- Freeze
- Unfreeze
- Toggle freeze

Keyboard:
- Key down
- Key up
- Key tap

Misc:
- Compound (trigger a list of other actions)
- System (run a script)
- Reconfigure (load another profile / client config)


Signs
-----

Signs are hand gestures in leapgim context. A sign can contain contain information about hand hand poses, native gestures, and time constraints.

We use the term 'sign' to provide a clear distinction from leap motion's native gestures circle, swipe, key tap and screen tap.


Setup
=====

Windows 10 dependencies
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


Ubuntu 14.04 dependencies
-------------------------

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
