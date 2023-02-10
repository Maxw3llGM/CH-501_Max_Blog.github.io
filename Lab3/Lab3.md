# Lab3

## "Words" Phase One

Word 1: Flow
	
* When using the haply with this sketch, it should feel as though you are in water.

Word 2: Nodes
	
* You should be able to sense the push and pull from the nodes (source and sink) within the environment.

Word 3: Particles
	
* When navigating the water, you should feel particles of objects hit and nudge the haply.

An axiom, as per its definition, is a point from which we may start to reason.

As such, these were the inital 3 "axioms" I used for my sketch. However, the developping process is never perfect and I ran into far too many problem trying to implement the second axiom "Nodes" that I had two days left before the deadline and still have not completed the movements for "Flow" and "Particles".

![](./photos/OStr.png)

 Thanks to Brian Eno's [Oblique Strategies](http://stoney.sb.org/eno/oblique.html) helping me break out of my designers block, I decided to drop the Nodes idea in the effort to find a new word. I did however learn alot about how to calculate forces for the Haply. As such I started from scratch and within one night I create a new set of words.
 
## "Words" Phase Two

### Testing Phase
This time in order to have any road blocks in the development phase, I tested a few ideas before I decided on my words.

I like the idea of particles moving across the simulation moving the Haply's end effector. As such I tested how easy it is to move static objects.

Add Video

Once achieved, I moved on to testing my next idea. I knew I wanted to use forces, by realizing that gravitational forces seem to be a bit too tricky for the moment, I decided to test with the concept of noise, or rather friction in this case. 
At first, I tried to use the hAPI's fBody class "setfriction" function but soon realized it did not have the same effect I had hope for as it did not yield any noticeable change in how the haply interacted with the fBody.
So, pulling from the knowledge I cultivated from trying to implement the nodes, I chose to input noise into the force values of the haply. This was achieved by adding a scaled randome value in the resulting end effector force variable:

`f_ee.add(4000*random(0.0,1.0),4000*random(0.0,1.0));`

Add video here:

Once I new this was possible I found my idea for the second word.

### Selection

Word 1: Particles

* Using FCircle objects, I wanted to slightly move and nudge the end effector of the haply to simulate the idea of bumping into something. 

Word 2: Noise

* Now that I know how to using noise into the force of the haply, otherwise called friction. I can guide the user through the environment with friction, where they can pass the haply over an area and feel a change in the simulations surface to be rougher.

Word 3: Space

* Using a wall with multiple holes and is thus a wall made up of equally spaced smaller walls. The use can percieve the gape in between the walls, until they might find one that can be moved out of the way and they can pass the wall.

## "Implementation" Phase 3

Now is time to realize these idea. I first started with the second word, "Noise".

Througout my designe process I always had in mind that the sketch must have an overarching motion to it, like left to write. As such, I though that I can use the noise to convey that idea to the use. I therefore decided to add a gradient to the noise based on it's horizontal position in space. One side will naturally induce more noise into the end effector than the other.

It's akin to concept of particles wanting to always go their lowers energy state, from High to Low potential energy.

![](./photos/ngrad.pdf)

Initially I decided to create a (as close too) continuous noise gradient
in the environemnt. 

This was achieved by taking the position of the end effector in the virtual space (not measured position, there is a different to be made here),

`ee_vposx = s.getAvatarPositionX(); ` ,

and then slowy increase the end effector forces noise level as it's going in a certain direction. This was rather simple to do, however it did not feel as though it was enough, there was not enough texture to it's feeling. So, I discretized it to create strips of friction within the environment.

![](./photos/fLines.pdf)

Each strip will also gradually increase and decrease to and from the max friction value based on ds, the max distance away from the mid point of the strip. I was able to achieve this by wraping the position of the end effector with a modulo function based on the amount of strips I want dividing up the max width of the world.

![](./photos/part.pdf)

Once that was completed, I proceeded to implement the particles. Since I have a horizontal direction, I thought of using the particles as a way to induce direction on the vertical axis. I thus decided to put them in the middle of the world going from top to bottom as a way create the idea of a stream of particles that the user is passing through.

Add Video. 

This was achieved by positioning 3 FCircle objects in the center of the sketch and having them move from top to bottom. Everytime they wrape around, the speed at which they are moving changes.

Finally, when implementing the idea of the walls I decided to change my approache and simple create one wall with two opening at the bottom and top of the wall so that the user needs to find them by touch. This choice was for simplicity reasons as there was too much feedback from the end effector due to the noise strips and the particles.

## Revision Phase Finale


TODO: ending version of vocabulary, Reflection on quality of expressiveness/ communication achieved. convert md into html, submit all


