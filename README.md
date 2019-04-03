# Leap Motion gesture input mapper

Leapgim takes hand signs as input and outputs other types of emulated computer input.

Demos: 

- https://www.youtube.com/watch?v=00KzsH7EuGs

- https://www.youtube.com/watch?v=cck8rIonXgw


## Installation



Prequisites: Robot.js dependencies.


Setup:

```
npm install leapgim
```


## Usage

Run the service with:

```
npm start
```

Open a browser at "http://localhost:3000" for audio.


## Background

Leap Motion is a sensor device for detecting detecting hand motions. A neat little piece of future technology. My first thought was that I would love to use the controller as a mouse replacement. Unfortunately the controller works with Leap-enabled software only. The goal of this project is to enable the Leap Motion controller to be used with other software also.

The basic premise of this project is that the Leap Motion controller can't replace both the mouse and the keyboard, since all the possible actions that a user could perform with a keyboard and a mouse can't feasibly be mapped into hand gestures. But it doesn't have to! A significant portion of desktop applications could be used with a small subset of possible mouse and keyboard input.

This project provides a way to define custom hand gestures and evoke actions based on those gestures. Supported actions include mouse and keyboard control, and shell scripts. Hand gesture customization allows timed, multi-step gestures to be defined, and includes as much as possible from the offical API.

Leapgim can be used as a prototyping platform to easily test a variety of hand gestures and their reliability.


### Default Gesture Mapping


- Mouse grab/release: Generic grabbing pose

- Mouse 1: Pinch index finger

- Mouse 2: Pinch ring finger

- Mouse scrollwheel: Circle gesture while mouse is inactive


Leapgim takes hand signs as input and outputs other types of emulated computer input. Recipes are how signs are translated into actions. The term is borrowed from IFTTT (https://ifttt.com/).

```
signs -> recipe -> actions
```


### Action Types

Mouse buttons:
- Mouse button down
- Mouse button up
- Mouse button click
- Mouse scroll up
- Mouse scroll down

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
- Compound action - execute a list of actions
- Exec - run scripts
- Load profile

Misc:
- Compound (trigger a list of other actions)
- System (run a script)
- Reconfigure (load another profile / client config)


### Signs

Signs are hand gestures in leapgim context. A sign can contain contain information about hand hand poses, native gestures, and time constraints.

We use the term 'sign' to provide a clear distinction from leap motion's native gestures circle, swipe, key tap and screen tap.


## Application Architecture

![](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/Zeukkari/leapgim/master/docs/architecture.puml)
