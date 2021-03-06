Introduction
------------

This is Freecell Solver version 2.34.x, a program that automatically
solves most layouts of Freecell, and similar Solitaire variants as
well as those of Simple Simon.

Freecell Solver is distributed under the MIT/X11 License 
( http://en.wikipedia.org/wiki/MIT_License ), a free, permissive, 
public-domain like, open-source license.

I hope you'll enjoy using it, and make the best of it.

-- Shlomi Fish ( http://www.shlomifish.org/ )

Building
--------

Read the file +INSTALL.txt+ for information on how to do that.

Usage
-----

The program is called "fc-solve". You invoke it like this:

    fc-solve board_file

board_file is the filename with a valid Freecell startup board. The file is
built as follows:

It has the 8 Freecell stacks.
Each stack contain its number of cards separated by a whitespace
and terminated with a newline character( it's important that the last stack
will also be terminated with a newline !). The cards in the line are ordered
from the bottom-most card in the left to the topmost card in the right.

A card string contains the card number (or rank) followed by the card deck. 
The card number is one of: +A,1,2,3,4,5,6,7,8,9,10,J,Q,K+. Alterantively
+T+ can be used instead of +10+. The card deck is one of:  +H,S,D,C+ (standing
for Hearts, Spades, Diamonds and Clubs respectively).

Here is an example board: (PySol board No. 24)

-----------------------
4S 2S 9S 8S QC 4C 2H
5H QH 3S AS 3H 4H QD
QS 9C 6H 9H 3C KC 3D
5D 2C JS 5S JH 6D AC
2D KD 10H 10S 10D 8D
7H JC KH 10C KS 7S
AH 5C 6C AD 8H JD
7C 6S 7D 4D 8C 9D
-----------------------

And another one: (PySol board No. 198246790)

-----------------------
KD JH 5H 7D 9H KS 9D
3H JD 5D 8H QH 7H 2D
4D 3C QS 3S 6C QC KC
10S 9C 6D 9S QD 8C 10D
10C 8S 7C 10H 2S AC
8D AS AH 4H JS 4S
6H 7S 4C 5C 5S JC
AD KH 6S 2H 3D 2C
-----------------------

You can specify the contents of the freecells by prefixing the line with
"FC:". For example:

-----------------------
FC: 3H QC
-----------------------

will specify that the cards 3 of hearts and queen of clubs are present in
the freecells. To specify an empty freecell use a "-" as its designator.

If there's another "FC:" line, the previous line will be overriden.

You can specify the contents of the foundations by prefixing the line with
"Founds:" and then using a format as follows:

-----------------------
Founds: H-5 C-A S-0 D-K
-----------------------

Hence, the deck ID followed by a dash followed by the card number in the
foundation. A suit that is not present will be assumed to be 0. Again, if 
there's more than one then the previous lines will be overriden.


The program will stop processing the input as soon as it read 8 lines of
standard stacks. Therefore, it is recommended that the foundations and
freecells lines will come at the beginning of the file.

The program will process the board and try to solve it. If it succeeds it
will output the states from the initial board to its final solution to the
standard output. If it fails, it will notify it.

For information about the various command-line switches that Freecell 
Solver accepts, read the +USAGE.txt+ file in this directory.

To solve Simple Simon boards append +--game simple_simon+ right after 
the "fc-solve" program name.

The board generation programs
-----------------------------

Several programs which can generate the initial boards of various Freecell
implementations can be found in the "board_gen/" sub-directory. Read the 
+README.txt+ file there for details on how they can be compiled and used.

In any case, they can save you the time of inputting the board yourself.
