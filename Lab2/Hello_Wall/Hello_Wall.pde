 /**
 **********************************************************************************************************************
 * @file       Haptic_Physics_Template.pde
 * @author     Steve Ding, Colin Gallacher
 * @version    V3.0.0
 * @date       27-September-2018
 * @brief      Base project template for use with pantograph 2-DOF device and 2-D physics engine
 *             creates a blank world ready for creation
 **********************************************************************************************************************
 * @attention
 *
 *
 **********************************************************************************************************************
 */
 
 
 
 /* library imports *****************************************************************************************************/ 
import processing.serial.*;
import static java.util.concurrent.TimeUnit.*;
import java.util.concurrent.*;
/* end library imports *************************************************************************************************/  



/* scheduler definition ************************************************************************************************/ 
private final ScheduledExecutorService scheduler      = Executors.newScheduledThreadPool(1);
/* end scheduler definition ********************************************************************************************/ 



/* device block definitions ********************************************************************************************/
Board             haplyBoard;
Device            widgetOne;
Mechanisms        pantograph;

byte              widgetOneID                         = 3;
int               CW                                  = 0;
int               CCW                                 = 1;
boolean           rendering_force                     = false;
/* end device block definition *****************************************************************************************/



/* framerate definition ************************************************************************************************/
long              baseFrameRate                       = 120;
/* end framerate definition ********************************************************************************************/ 



/* elements definition *************************************************************************************************/

/* Screen and world setup parameters */
float             pixelsPerCentimeter                 = 40.0;

/* generic data for a 2DOF device */
/* joint space */
PVector           angles                              = new PVector(0, 0);
PVector           torques                             = new PVector(0, 0);

/* task space */
PVector           pos_ee                              = new PVector(0, 0);
PVector           f_ee                                = new PVector(0, 0); 

/* World boundaries */
FWorld            world;
float             worldWidth                          = 25.0;  
float             worldHeight                         = 10.0; 

float             edgeTopLeftX                        = 0.0; 
float             edgeTopLeftY                        = 0.0; 
float             edgeBottomRightX                    = worldWidth; 
float             edgeBottomRightY                    = worldHeight;

/* Initialization of virtual tool */
HVirtualCoupling  s;

/* Hello Wall*/
FBox wall_1;
FBox wall_2;
FBox wall_3;
FBox floor_1;
FBox floor_2;
FBox floor_3;
FBox floor_4;
FPoly corner_1;
FPoly corner_2;
FPoly corner_3;
FPoly corner_4;
FPoly corner_5;
FCircle ball;
FCircle ball_2;

/* end elements definition *********************************************************************************************/



/* setup section *******************************************************************************************************/
void setup(){
  /* put setup code here, run once: */
  
  /* screen size definition */
  size(1000, 400);
  
  
  /* device setup */
  
  /**  
   * The board declaration needs to be changed depending on which USB serial port the Haply board is connected.
   * In the base example, a connection is setup to the first detected serial device, this parameter can be changed
   * to explicitly state the serial port will look like the following for different OS:
   *
   *      windows:      haplyBoard = new Board(this, "COM10", 0);
   *      linux:        haplyBoard = new Board(this, "/dev/ttyUSB0", 0);
   *      mac:          haplyBoard = new Board(this, "/dev/cu.usbmodem1411", 0);
   */
  haplyBoard          = new Board(this, Serial.list()[2], 0);
  widgetOne           = new Device(widgetOneID, haplyBoard);
  pantograph          = new Pantograph();
  
  println(Serial.list());

  
  widgetOne.set_mechanism(pantograph);
  
  widgetOne.add_actuator(1, CCW, 2);
  widgetOne.add_actuator(2, CW, 1);

  widgetOne.add_encoder(1, CCW, 241, 10752, 2);
  widgetOne.add_encoder(2, CW, -61, 10752, 1);
  
  widgetOne.device_set_parameters();
  
  
  /* 2D physics scaling and world creation */
  hAPI_Fisica.init(this); 
  hAPI_Fisica.setScale(pixelsPerCentimeter); 
  world               = new FWorld();
  
  
  /* Wall Setup */
  wall_1 = new FBox(0.75,7);
  wall_1.setPosition(worldWidth/2+1.5, edgeBottomRightY-4);
  wall_1.setFill(0,0,0);
  wall_1.setStatic(true);  
  world.add(wall_1);
  
  wall_2 = new FBox(0.75,5.75);
  wall_2.setPosition(worldWidth/2-1.5, edgeBottomRightY-4.65);
  wall_2.setFill(0,0,0);
  wall_2.setStatic(true);  
  world.add(wall_2);
  
  wall_3 = new FBox(0.75,5.);
  wall_3.setPosition(edgeBottomRightX-2.36, edgeBottomRightY-4.8);
  wall_3.setFill(0,0,0);
  wall_3.setStatic(true);  
  world.add(wall_3);
  
  floor_1 = new FBox(1,0.30);
  floor_1.setPosition(worldWidth/2+0.95, edgeBottomRightY-2.2);
  floor_1.setFill(0,0,0);
  floor_1.setStatic(true);
  world.add(floor_1);
  
  floor_2 = new FBox(1,0.30);
  floor_2.setPosition(worldWidth/2-0.95, edgeBottomRightY-2.2);
  floor_2.setFill(0,0,0);
  floor_2.setStatic(true);
  world.add(floor_2);
  
  floor_3 = new FBox(8,0.75);
  floor_3.setPosition(edgeBottomRightX-6., edgeBottomRightY-2.2);
  floor_3.setFill(0,0,0);
  floor_3.setStatic(true);
  world.add(floor_3);
  
  floor_4 = new FBox(8,0.75);
  floor_4.setPosition(edgeBottomRightX-6, 0+2.89);
  floor_4.setFill(0,0,0);
  floor_4.setStatic(true);
  world.add(floor_4);
  
  corner_1 = new FPoly();
  corner_1.vertex(edgeBottomRightX, edgeBottomRightY); 
  corner_1.vertex(edgeBottomRightX, edgeBottomRightY-2);
  corner_1.vertex(edgeBottomRightX-2, edgeBottomRightY);
  corner_1.setFill(0,0,0);
  corner_1.setStatic(true);
  world.add(corner_1);
  
  corner_2 = new FPoly();
  corner_2.vertex(0, edgeBottomRightY); 
  corner_2.vertex(0, edgeBottomRightY-2);
  corner_2.vertex(0+2, edgeBottomRightY);
  corner_2.setFill(0,0,0);
  corner_2.setStatic(true);
  world.add(corner_2);
  
  corner_3 = new FPoly();
  corner_3.vertex(worldWidth/2, 0); 
  corner_3.vertex(worldWidth/2, 2);
  corner_3.vertex(worldWidth/2+2, 0);
  corner_3.setFill(0,0,0);
  corner_3.setStatic(true);
  world.add(corner_3);
  
  corner_4 = new FPoly();
  corner_4.vertex(worldWidth/2, 0); 
  corner_4.vertex(worldWidth/2, 2);
  corner_4.vertex(worldWidth/2-2, 0);
  corner_4.setFill(0,0,0);
  corner_4.setStatic(true);
  world.add(corner_4);
  
  corner_5 = new FPoly();
  corner_5.vertex(edgeBottomRightX, 0); 
  corner_5.vertex(edgeBottomRightX, 2);
  corner_5.vertex(edgeBottomRightX-2, 0);
  corner_5.setFill(0,0,0);
  corner_5.setStatic(true);
  world.add(corner_5);
  
  ball = new FCircle(1);
  ball.setDensity(.5);
  ball.addForce(10.0,10.0);
  ball.setPosition(edgeBottomRightX-10, edgeBottomRightY-2);
  
  ball_2 = new FCircle(1);
  ball_2.setDensity(.5);
  ball_2.addForce(10.0,10.0);
  ball_2.setPosition(edgeBottomRightX-8, edgeBottomRightY-4);
  
  world.add(ball);
  world.add(ball_2);
  
  
  /* Setup the Virtual Coupling Contact Rendering Technique */
  s                   = new HVirtualCoupling((0.5)); 
  s.h_avatar.setDensity(2); 
  s.h_avatar.setFill(255,0,0); 
  s.init(world, edgeTopLeftX+worldWidth/2, edgeTopLeftY+2); 
  
  /* World conditions setup */
  world.setGravity((0.0), (300.0)); //1000 cm/(s^2)
  world.setEdges((edgeTopLeftX), (edgeTopLeftY), (edgeBottomRightX), (edgeBottomRightY)); 
  world.setEdgesRestitution(.4);
  world.setEdgesFriction(0.5);
  
  world.draw();
  
  
  /* setup framerate speed */
  frameRate(baseFrameRate);
  
  
  /* setup simulation thread to run at 1kHz */ 
  SimulationThread st = new SimulationThread();
  scheduler.scheduleAtFixedRate(st, 1, 1, MILLISECONDS);
}



/* draw section ********************************************************************************************************/
void draw(){
  /* put graphical code here, runs repeatedly at defined framerate in setup, else default at 60fps: */
  background(255);
  world.draw(); 
}
/* end draw section ****************************************************************************************************/



/* simulation section **************************************************************************************************/
class SimulationThread implements Runnable{
  
  public void run(){
    /* put haptic simulation code here, runs repeatedly at 1kHz as defined in setup */
    rendering_force = true;
    
    if(haplyBoard.data_available()){
      /* GET END-EFFECTOR STATE (TASK SPACE) */
      widgetOne.device_read_data();
    
      angles.set(widgetOne.get_device_angles()); 
      pos_ee.set(widgetOne.get_device_position(angles.array()));
      pos_ee.set(pos_ee.copy().mult(200));  
    }
    
    s.setToolPosition(edgeTopLeftX+worldWidth/2-(pos_ee).x+2, edgeTopLeftY+(pos_ee).y-7); 
    s.updateCouplingForce();
    f_ee.set(-s.getVCforceX(), s.getVCforceY());
    f_ee.div(20000); //
    
    torques.set(widgetOne.set_device_torques(f_ee.array()));
    widgetOne.device_write_torques();
    
  
    world.step(1.0f/1000.0f);
  
    rendering_force = false;
  }
}
/* end simulation section **********************************************************************************************/



/* helper functions section, place helper functions here ***************************************************************/

/* end helper functions section ****************************************************************************************/
