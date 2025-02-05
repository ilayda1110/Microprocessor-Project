# Microprocessor Project

## Group Members
İlhan Özen\
İlayda AY

## Objective
Create a project using a 7-segment display, two buttons, and two LEDs to design a competitive game. 
The countdown will start from 3, and players must press their buttons strategically to win based on 
the following conditions. 

## Specifications 
### Countdown Mechanism: 
  - The 7-segment display will count down from 3 to 0, decreasing by 1 every second.
  - When the countdown reaches 0, the first player to press their button will win, and 
    their corresponding LED will light up. 
### Win Conditions: 
  - If a player presses their button before the countdown reaches 0, the other player 
    automatically wins, and their LED will light up. 
  - If both players wait until the countdown reaches 0, the LED of the first player to 
    press their button will light up. 
### Game Restart: 
  - After one player wins, the game will automatically restart 3 seconds later. 
### 7-Segment Display Behavior After Countdown: 
  - Once the countdown reaches 0, the 7-segment display will show a "-" (dash) in the 
    center to indicate the game has ended.
### Game Reset:
  - Design a mechanism to manually reset the game for another round.

## Explanation of Code

First, we start with initializations such as initialization of stack pointer and disabling watchdog timer.
We also set up our interrupt vectors and the labels they jump to for port 1 and port 2.\
\
We configure pins which we want to use of ports 1 and 2 as digital input/output by clearing 
corresponding bits.\
\
After that, we set direction of our pins as input or output. For specified input pins, we enable pull-up 
resistors.\
\
For interrupt handling, we enabled interrupts on the pins we connected to the buttons and also 
configured them to trigger interrupts.\
\
We defined 4 states for the 7-segment display: 3, 2, 1 and end (-). We set the bits for each state 
according to the way we connected the 7-segment in the circuit and whether the 7-segment is an 
anode or a cathode (the one we used was an anode). Also, we use a control register (r6) to mark if 
the timer has ended.\
\
To slow down the transition between states, we used a nested loop mechanism that takes exactly 1 
second (labels “delay” and “dloop”).\
\
When either player presses their button, it triggers an interrupt and jumps to label “but_ISR”. We 
move the interrupt flag to a temporary register (r7) and display (-) to indicate the game has ended. 
Depending on whether the timer has ended or not (by checking the control register), we jump to; 
label “win” if the button was pressed after the timer has ended, label “lose” if the button was 
pressed before the timer has ended.\
\
The “win” and “lose” labels check if the button with the yellow LED was pressed (by checking the 
temporary register); if so the labels light the yellow and blue LED respectively, if the other button was 
pressed the labels light the blue and yellow LED respectively.\
\
After a player wins, the game ends and waits for exactly 3 seconds before restarting (label “end”). 
If no player presses their button after the countdown ends, the code enters an infinite loop until it is 
interrupted (label “noPress”).\
\
When the reset button is pressed, it triggers an interrupt and jumps to label “but_ISR_Reset”. This 
jumps to the “start” label which resets the game.

## Video of Final Project

[![Video Title](https://img.youtube.com/vi/-ZFJly4FaF4/0.jpg)](https://www.youtube.com/watch?v=-ZFJly4FaF4)
