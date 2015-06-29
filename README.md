NumEd - The Numerical Editor
----------------------------
The main purpose of this editor is to provide a way to edit text only with the
numerical keyboard. It may sound silly, but it allows you to interact with text
using only one hand. Also, it is fun, you have to try it!

You may see great influence of vim in this project. If you still haven't tried
it out - it's the best text editor ever.

Running
-------
It is as simple as typing
```
perl numed.pl filename.txt
```
Your machine must be able to run perl with Curses::IO library. Also, you have to
have curses installed.

Features:
---------
- multiple edit modes
- T9 text input based on simple dictionary file
- portable curses display

Current development:
--------------------
- working on T9 input overall experience
- implementing manual input for words not in dictionary

Bugs and ideas:
-----
Please report bugs and submit new ideas by Github issues.
