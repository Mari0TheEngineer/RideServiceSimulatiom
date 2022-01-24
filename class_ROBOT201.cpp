//------------------------------------------------------------------
// File name:   class_ROBOT201.cpp
// Assign ID:   TERMproject
// Due Date:    12/07/2021      
//
// Purpose:     Derived robot class implementation.
//
// Author:      brownM105 Mario Brown
//------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <cstdlib>
#include <cmath>
using namespace std;

#include "class_ROBOT101.h"
#include "class_ROBOT201.h"

//-----------------------------------------------------------------
// Constructor: use specified grid (MINx, MINy) to (MAXx, MAXy)..
//-----------------------------------------------------------------
ROBOT201::ROBOT201( ):ROBOT101()
{
   inService = false;
   Current.xpos = Current.ypos = 0;
   gridLO.xpos = gridLO.ypos = 0;
   gridHI.xpos = gridHI.ypos = 20;
   Establish_Grid(0,0,20,20);
   Power = 500;
   totDist = 0;
}

//-----------------------------------------------------------------
// Set Grid
//-----------------------------------------------------------------
void ROBOT201::Set_Grid(LOCATION MIN, LOCATION MAX)
{
    //Check values
    if(MIN.xpos >= 0 && MIN.xpos < MAX.xpos && MIN.ypos >= 0 
      && MAX.xpos > 0 && MAX.ypos > 0 && MIN.ypos < MAX.ypos)
    {
        gridLO = MIN;
        gridHI = MAX;
        Establish_Grid(MIN.xpos,MIN.ypos,MAX.xpos,MAX.ypos);
    }
    else return;
}

//-----------------------------------------------------------------
// Set Robot ID.
//-----------------------------------------------------------------
void ROBOT201::Set_RobotID(string ID)
{
    RobotID = ID;
}

//-----------------------------------------------------------------
// Get Robot ID.
//-----------------------------------------------------------------
string ROBOT201::Get_RobotID()
{
    return RobotID;
}

//-----------------------------------------------------------------
// Set Robot Power
// Power level: 0-1000
//-----------------------------------------------------------------
void ROBOT201::Set_Power(float power)
{
    //check for valid power
    if (power < 0 || power > 1000)
        return;
    else Power = power;
}

//-----------------------------------------------------------------
// Get current power level.
//-----------------------------------------------------------------
float ROBOT201::Get_Power()
{
    return Power;
}

//-----------------------------------------------------------------
// Get distance moved while in service.
//-----------------------------------------------------------------
float ROBOT201::Get_Distance()
{
   return totDist;
}

//-----------------------------------------------------------------
// Return whether robot is in service.
// 
//-----------------------------------------------------------------
bool ROBOT201::InService()
{ 
   return inService;       
}

//-----------------------------------------------------------------
// Place make robot in-service.
//-----------------------------------------------------------------
void ROBOT201::Place_InService()
{
    if(!inService)
        StartUp(0,0);
    inService = true;
}

//-----------------------------------------------------------------
// Return current location. 
//-----------------------------------------------------------------
LOCATION ROBOT201::Get_CurLocation()
{
    //Update the Current struct with ROBOT101 values
    Current.xpos = Get_Xcoord();
    Current.ypos = Get_Ycoord();
    return Current;
}

//-----------------------------------------------------------------
// Move from current location to destination if robot.
//-----------------------------------------------------------------
bool ROBOT201::MoveTo(LOCATION dest)
{
    //Check for invalid values and return false
    if(!inService || dest.xpos > gridHI.xpos || dest.xpos < gridLO.xpos ||
           dest.ypos > gridHI.ypos || dest.ypos < gridLO.ypos) return false;
    
    //Call this function to get the most up-to-date values from ROBOT101 
    Get_CurLocation();
    
    //calculate distance between current position and future destination
    float x_dist = dest.xpos - Current.xpos;
    float y_dist = dest.ypos - Current.ypos;

    // Check for valid values and return true
    if(Current.ypos+y_dist >= gridLO.ypos && Current.ypos+y_dist <= gridHI.ypos 
       && Current.xpos+x_dist >= gridLO.xpos && Current.xpos+y_dist <= gridHI.xpos)
    {
        // East = positive x distance
        if(x_dist > 0)
        {
            for(int i = 0; i < x_dist; i++)
            {
                if(Power > 0)
                {
                    Move('E');
                    Current.xpos =+ 1;
                    totDist = totDist+1;
                    Power = Power-1;
                }
                if(Power == 0)
                {
                    inService = false;
                }
            } 
        }
        // West = negative x distance
        else if(x_dist < 0)
        {
            for(int i = 0; i < abs(x_dist); i++)
            {
                if(Power > 0)
                {
                     Move('W');
                     Current.xpos =- 1;
                     totDist = totDist+1;
                     Power = Power-1;   
                }  
                if(Power == 0)
                {
                    inService = false;
                }
            } 
        }
        
        // North = positive y distance
        if(y_dist > 0)
        {
            for(int i = 0; i < y_dist; i++)
            {
                if(Power > 0)
                {
                     Move('N');
                     Current.ypos =+ 1;
                     totDist = totDist+1;
                     Power = Power-1;   
                }
                if(Power == 0)
                {
                    inService = false;
                }
            }
        }
        // South = negative y distance
        else if(y_dist < 0)
        {
            for(int i = 0; i < abs(y_dist); i++)
            {
                if(Power > 0)
                {
                     Move('S');
                     Current.xpos =- 1;
                     totDist = totDist+1;
                     Power = Power-1;   
                }
                if(Power == 0)
                {
                    inService = false;
                }
            }
        }
       
        return true;
    }
    else return false;
}

//-----------------------------------------------------------------
// Take robot out of service.
//-----------------------------------------------------------------
void ROBOT201::Take_OutOfService()
{
    inService = false;
}