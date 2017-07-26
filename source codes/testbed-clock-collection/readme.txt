The CCSwispfiles folder contains 
- wisp-base: needed for any wisp application
- run-once: you need to run this app once (in a wisp lifetime) to initialize the random table, before any other application
- readTime: This is the program to collect timer values from the tag, both method 1 and method 2 use the same main.c, to change from method, search for "CHANGE" (it is located twice in the file) and follow the instruction
