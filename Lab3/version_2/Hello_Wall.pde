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
FBox wall_4;



FCircle ball;
FCircle ball_2;
FCircle ball_3;

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
  wall_1 = new FBox(0.75,(worldHeight-3));
  wall_1.setPosition(worldWidth/2+6, 5);
  wall_1.setFill(0,0,0);
  wall_1.setStatic(true);  
  world.add(wall_1);
  
  //wall_1 = new FBox(0.75,(worldHeight-2)/3);
  //wall_1.setPosition(worldWidth/2+6, 2.4);
  //wall_1.setFill(0,0,0);
  //wall_1.setStatic(true);  
  //world.add(wall_1);
  
  //wall_2 = new FBox(0.75,(worldHeight-2)/3);
  //wall_2.setPosition(worldWidth/2+6, (worldHeight-2)/3 + 2.8);
  //wall_2.setFill(0,0,0);
  //wall_2.setStatic(true);  
  //world.add(wall_2);
  
  //wall_3 = new FBox(0.75,(worldHeight-2)/3);
  //wall_3.setPosition(worldWidth/2+6, (worldHeight-2)*2/3 + 3.2);
  //wall_3.setFill(0,0,0);
  //wall_3.setStatic(false);  
  //world.add(wall_3);
  
  //wall_4 = new FBox(0.75,7);
  //wall_4.setPosition(worldWidth/2+4, edgeBottomRightY-5);
  //wall_4.setFill(0,0,0);
  //wall_4.setStatic(true);  
  //world.add(wall_4);
  // floor_1 = new FBox(1,0.30);
  // floor_1.setPosition(worldWidth/2+0.95, edgeBottomRightY-2.2);
  // floor_1.setFill(0,0,0);
  // floor_1.setStatic(true);
  // world.add(floor_1);
  
  ball = new FCircle(2);
  ball.setPosition(edgeBottomRightX-worldWidth/2, worldHeight/2);
  ball.setStatic(true);
  
  ball_2 = new FCircle(2);
  ball_2.setPosition(edgeBottomRightX-worldWidth/2+3, worldHeight/2);
  ball_2.setStatic(true);

  ball_3 = new FCircle(2);
  ball_3.setPosition(edgeBottomRightX-worldWidth/2-3, worldHeight/2);
  ball_3.setStatic(true);

  world.add(ball);
  world.add(ball_2);
  world.add(ball_3);
  
  /* Setup the Virtual Coupling Contact Rendering Technique */
  s                   = new HVirtualCoupling((0.5)); 
  s.h_avatar.setDensity(2); 
  s.h_avatar.setFill(255,0,0); 
  s.init(world, edgeTopLeftX+worldWidth/2, edgeTopLeftY+2); 
  
  /* World conditions setup */
  world.setGravity((0.0), (0.0)); //1000 cm/(s^2)
  world.setEdges((edgeTopLeftX), (edgeTopLeftY), (edgeBottomRightX), (edgeBottomRightY)); 
  world.setEdgesRestitution(.4);
  world.setEdgesFriction(0.5);
  
  //world.draw();
  
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
  //world.draw(); 
}
/* end draw section ****************************************************************************************************/



/* simulation section **************************************************************************************************/
class SimulationThread implements Runnable{
  float dy = 1.0f/1000.0f;
  float vel_1 = 3.0;
  float vel_2 = 2.0;
  float vel_3 = 1.0;
  float ds = 0.05;
  float dt = worldWidth/100;
  float ee_vposx = 0.0;
  float centerx = worldWidth/2;
  float noise_mult = 0.0;
  float noise_mult_1 = 0.0;
  float noise_level = 0.0;
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
    
    // if(pos_ee.x < 0){
    //   vari = 10000*Math.sin(count/1000);
    //   oscForce.set((float) vari,0.0);

    // }
    // else if (pos_ee.x >= 0 && oscForce.x != 0) {
    //   oscForce.set(0.0,0.0);
    // }
    

    // else if (pos_ee.x >= 0 && s.getVirtualCouplingStiffness()!= 250000.0f) {
    //   s.setVirtualCouplingDamping(250000.0f);
    // }
    
    ball_motion(ball,0.0,dy*vel_1);
    ball_motion(ball_2,0.0,dy*vel_2);
    ball_motion(ball_3,0.0,dy*vel_3);

    //println(ball.getY());
    if(ball.getY() < (dy * vel_1)){
      vel_1 = random(1.0,10.0);
    }
    if(ball_2.getY() < (dy * vel_2)){
      vel_2 = random(1.0,10.0);
    }
    if(ball_3.getY() < (dy * vel_3)){
      vel_3 = random(1.0,10.0);
    }
    s.setToolPosition(centerx-(pos_ee).x+2, edgeTopLeftY+(pos_ee).y-7); 

    s.updateCouplingForce();
    ee_vposx = s.getAvatarPositionX();
    //println(ee_vposx);
    //println(noise_mult," | ",s.getAvatarPositionX(), " | ",edgeTopLeftX+worldWidth/2, " | ",edgeTopLeftX+worldWidth/2+1, " | ");
    f_ee.set(-s.getVCforceX(), s.getVCforceY());

  // noise gradient 1

    // if(ee_vposx > centerx+1){
    //   if(ee_vposx < centerx+2){
    //     noise_mult = mapit(ee_vposx,centerx+1,centerx+2,0.0,1.0);
        
    //   }
    //   f_ee.add(4000*random(0.0,1.0),4000*random(0.0,1.0)).mult(noise_mult);
    // }
    //if(ee_vposx < centerx+8){
    //  if(ee_vposx > centerx+1){
    //    noise_mult_1 = mapit(ee_vposx,centerx+8,centerx+1,0.0,1.0);
    //    println(noise_mult_1,ee_vposx, centerx+8,centerx);
    //  }
    //  f_ee.add(-8000.0,0).mult(noise_mult_1);
      
    //}
    

  // friction equally spaced noisy lines 
    if(ee_vposx > 1.0+ds && ee_vposx < worldWidth-1-ds){  
      if(ee_vposx % dt > dt-ds) noise_mult = mapit(ee_vposx % dt,dt-ds,dt,0.0,1.0);
      if(ee_vposx % dt < ds) noise_mult = mapit(ee_vposx % dt,0,ds,1.0,0.0);
      noise_level = mapit(ee_vposx,1.0,worldWidth-1,8000,3000); 
      //println(ee_vposx % dt, " | ", ds ," | ", noise_level);
      f_ee.add(noise_level*random(0.0,1.0),noise_level*random(0.0,1.0)).mult(noise_mult);
    }
    s.updateCouplingForce();
    f_ee.add(-s.getVCforceX(), s.getVCforceY());
    f_ee.div(20000); //
    torques.set(widgetOne.set_device_torques(f_ee.array()));
    widgetOne.device_write_torques();
    
  
    world.step(1.0f/1000.0f);
    rendering_force = false;
  }
}
/* end simulation section **********************************************************************************************/



/* helper functions section, place helper functions here ***************************************************************/
float mapit(float x, float in_min, float in_max, float out_min, float out_max)
{
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

void ball_motion(FCircle b,float x_inc, float y_inc){
  b.setPosition((b.getX()+x_inc)%(worldWidth-2),(b.getY()+y_inc)%(worldHeight-2));
}

/* end helper functions section ****************************************************************************************/
