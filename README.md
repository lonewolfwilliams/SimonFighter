SimonFighter
============

Flash Game in Flixel, what happens if you try to mix Simon (the old school electronic memory game) with Streetfighter 2

-----------------
Game Instructions
-----------------

This is a two player game, currently with no instructions title screen or game over screen :P The game uses the arrow keys. 

Players take it in turns to try and remember a growing sequence of keypresses, each keypress remembered will result in a successful attack on the other player each mistake will result in your attack being blocked.

When the game starts the first key in the sequence will be displayed briefly, then the starting player (left or right) will be chosen at random, this player must press the key they have just been shown. Currently the sequence length is one.

Another key will be displayed, this key is then added to the sequence (length now two.)

Play passes to the other player who must now remember two keys, the first key in the sequence and the one they have just been shown.

Play continues until one player runs out of energy. (then a blank game over screen will be shown) 

------------------
Build Instructions
------------------
This is a flashDevelop 4 project with dependencies on This is an [Flixel](http://flixel.org/). (v2.35 currently) and [Photonstorm's Flixel Power tools](https://github.com/photonstorm/Flixel-Power-Tools) (1.9 currently)