//------------------------------------------------------------------
// File name:   class_ROBOT100.cpp
// Assign ID:   TERMproject 
// Due Date:    11/07/21  
//
// Purpose:     Base robot class implementation.
//
// Author:      brownM105 Mario Brown
//------------------------------------------------------------------

#include <iostream>
#include "class_ROBOT101.h"
//#include "class_POSITION.h"
using namespace std;

//---------------------------------------------------------------------
// Constructor: default grid is (0,0) to (10,10);
// Make inactive, and set current position to (0,0).
//---------------------------------------------------------------------
ROBOT101::ROBOT101()
{  
   xmin = ymin = 0;
   xmax = ymax = 10;
   curX = curY = 0;
   Active = false; 
}
//---------------------------------------------------------------------
// Set grid to specified (Xmin, Ymin) to (Xmax, Ymax) only if
// the grid is valid..
//---------------------------------------------------------------------
void ROBOT101::Establish_Grid(float Xmin, float Ymin, float Xmax, float Ymax)
{
    //Check values
    if(Xmin >= 0 && Xmin < Xmax && Ymin >= 0 && Ymin < Ymax
      && Xmax > 0 && Ymax > 0)
    {
        xmin = Xmin;
        ymin = Ymin;
        xmax = Xmax;
        ymax = Ymax;
    }
    else return;    
}

//---------------------------------------------------------------------
// Display the grid coordinates.
//---------------------------------------------------------------------
void ROBOT101::Show_Grid(string Label)
{
    cout << Label << endl;
    cout << "(" << xmin << "," << ymin << ")" << endl;
    cout << "(" << xmax << "," << ymax << ")" << endl;
}

//---------------------------------------------------------------------
// Activate robot in specified starting position only if position is valid..
//---------------------------------------------------------------------
void ROBOT101::StartUp(float xStart, float yStart)
{
    if(xStart >= xmin && xStart <= xmax && yStart >= ymin && yStart <= ymax)
    {
      Active = true;
      curX = xStart;
      curY = yStart;  
    }
}

//---------------------------------------------------------------------
// Return whether robot is active.
//---------------------------------------------------------------------
bool ROBOT101::IsActive()
{
    return Active;
}

//---------------------------------------------------------------------
// Return current robot position x-coordinate..
//---------------------------------------------------------------------
float ROBOT101::Get_Xcoord()
{
    return curX;
}

//---------------------------------------------------------------------
// Return current robot position y-coordinate..
//---------------------------------------------------------------------
float ROBOT101::Get_Ycoord()
{
    return curY;
}

//---------------------------------------------------------------------
// Attempt move [ N S E W ] or [U D R L]. Return false when move prohibited.
// due to: being inactive, or the move would take robot off grid.
//---------------------------------------------------------------------
bool ROBOT101::Move(char direction)
{
    switch (toupper(direction))
    {
        // Cases going North/Up
        case 'N' :
        case 'U' : if(Active == true &&  curY+1 >= ymin && curY+1 <= ymax)
                   {
                        curY = curY+1;
                        return true;
                   }
                   else return false;
                   break;

        // Cases going South/Down
        case 'S' : 
        case 'D' : if(Active == true && curY-1 >= ymin && curY-1 <= ymax)
                   {
                        curY = curY-1;
                        return true;
                   }
                   else return false;
                   break;
        
        // Cases going East/Right    
        case 'E' : 
        case 'R' : if(Active == true && curX+1 >= xmin && curX+1 <= xmax)
                   {
                        curX = curX+1;
                        return true;
                   }
                   else return false;
                   break;
        
        // Cases going West/Left
        case 'W' :        
        case 'L' : if(Active == true && curX-1 >= xmin && curX-1 <= xmax)
                   {
                        curX = curX-1;
                        return true;
                   }
                   else return false;
                   break;

        default:   cout << "UNKNOWN Command '" << direction << "' ... retry" << endl;
                   return false;
      }//switch

}

//---------------------------------------------------------------------
// Show position of active robot; use caller-supplied label..
//---------------------------------------------------------------------
void ROBOT101::Show_Position(string Label)
{
    cout << Label << endl;
    cout << "(" << curX << "," << curY << ")" << endl;
}

//---------------------------------------------------------------------
// Shutdown (make robot inactive).
//---------------------------------------------------------------------
void ROBOT101::ShutDown()
{
    Active = false;
}