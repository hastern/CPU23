CPU23
=====

an esoteric 23-bit processing unit with a RISC instruction set.

What's the purpose - why create another CPU?
--------------------------------------------

I find the design and complexity of a modern CPU very intriguing.
As a computer engineering student, I want to understand what has to be done in order for a circuit to act as a CPU.
As a tinker, I enjoy developing things from scratch.
A logical result was the creation my very own CPU design.

I'm not intending to make the next big CPU design, useful for everyone and -thing;  I merely try to understand the steps that are necessary to make this work.

Since developing a CPU is a complex, long term project, I try to keep everything as simple as possible. Starting with an elementary instruction set with the minimum of instruction needed to be turing complete and provide at least a bit of  comfort writing assembly.  

Is there a reason for 23-Bit? 
-----------------------------

I didn't had a logical reason for choosing this bit-width in particular.
Mostly it was a choice of fun. 
The first idea was to choose 42 bits, as a reference to Douglas Adams wonderful "Hitchhikers Guide to Galaxy"-Novels.
But I didn't found any use for such wide data words.
The next "magic number" that came to my mind, was 23 with all its ridiculous conspiracy theories waving around it.
After some initial brainstorming, I concluded that 23 Bits are sufficient for my purpose. 
To get a better alignment with the powers of 2, found in computer science, I added a non-execution-Bit as 24 Bit, which perfectly melds itself with the conspiracy theme and the (theoretical) idea of hack-safe computing.
As a result, I believed it to be fun, to have every document about this project conspiracy themed. Don't take every disclaimer serious ;)


