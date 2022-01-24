//------------------------------------------------------------------
// File name:   ROBOTapp.cpp
// Assign ID:   TERMproject
// Due Date:    12/07/2021      
//
// Purpose:     App similar to Uber where a robot will pick up person
//              at specified set of coordinates and take them to another 
//              specified set of coordinates. Based on the trip distance
//              from point A to B, the person will be charged. The 
//              trip bill will include the trip cost, tax, and any tip.
           
//
// Author:      brownM105 Mario Brown
//------------------------------------------------------------------
#include <iostream>
#include <iomanip>
#include <cstdlib>
#include <cmath>
#include <vector>
using namespace std;

#include "class_ROBOT101.h"
#include "class_ROBOT201.h"

//STRUCT
#ifndef LOCATION_STRUCT
#define LOCATION_STRUCT
struct LOCATION
{
   float xpos, ypos;
};
#endif

//global variables
const int num_bots = 5;

//All robots
ROBOT201 r[num_bots];

//Functions
void request_trip();

int main()
{
    //welcome screen
    cout << "===============================================\n\n";
    cout << "               Robot Pickup Service              ";
    cout << "\n\n===============================================\n\n";
    
    //set robot IDs
    for(int i = 0; i < num_bots; i++) r[i].Set_RobotID(to_string(i + 1));
    
    //place robots 1-4 in service
    r[0].Place_InService();
    r[1].Place_InService();
    r[2].Place_InService();
    r[3].Place_InService();
    
    //set robots in random start locations
    r[0].StartUp(8,12);        //Robot 1
    r[1].StartUp(0,5);         //Robot 2
    r[2].StartUp(5,17);        //Robot 3
    r[3].StartUp(13,6);        //Robot 4
    r[4].StartUp(20,12);       //Robot 5
    
    /*
    //show map using the ROBOT201 default grid
    float size = 21
    string map_x[21];
    for(int i =0; i<size; i++) map_x[i]=" "; 
    string map_y[21];
    for(int i =0; i<size; i++) map_y[i]=" "; 
    float grid[][] ={map_x[],}
    */
    
    while(1)
    {
        request_trip();
    }
    
}

void request_trip()
{
    //variables
    int bot_num;
    float pickup_distance[num_bots], totdist_needed, trip_distance;
    char response;
    float tip, ride_cost, taxes, total;
    const float travel_rate = 1.25, tax = 0.06;
    LOCATION pickup, dropoff;
    
    
    //available robots vectors used to narrow which can be used for the requested trip
    vector <ROBOT201> available_bots;
    vector <float> available_pickups;
    
    cout << "Enter your pickup location (x y): ";
    cin >> pickup.xpos >> pickup.ypos;
    
    cout << "Enter your destination location (x y): ";
    cin >> dropoff.xpos >> dropoff.ypos;
    cout << endl << endl;
    
    trip_distance = abs(dropoff.xpos - pickup.xpos) +
                      abs(dropoff.ypos - pickup.ypos);
    
    //calculate pickup distance and trip total distance 
    for(int i =0; i < num_bots; i++)
    {
        if(r[i].InService() == true )
        {
            pickup_distance[i] = abs(r[i].Get_Xcoord() - pickup.xpos) + 
                                abs(r[i].Get_Ycoord() - pickup.ypos);
            totdist_needed = pickup_distance[i] + trip_distance;
           
            if(r[i].Get_Power() > totdist_needed)
            {
                available_bots.push_back(r[i]);
                available_pickups.push_back(pickup_distance[i]);  
            }  
        }
    }
    
    //find closest bot
    float closest_pickupDist = available_pickups[0];
    for(int i = 1; i < available_pickups.size(); i++)
    {
        if (available_pickups[i] < closest_pickupDist)
        {
           closest_pickupDist = available_pickups[i];
           bot_num = i; 
        } 
    }
    
    cout << "Robot " << available_bots[bot_num].Get_RobotID() << " is on the way." << endl;
    cout << "Distance away: " << closest_pickupDist << " miles\n\n";
    
    //closest_pickupDist = 500;
    
    if(available_bots[bot_num].MoveTo(pickup))
    {
        available_bots[bot_num].Show_Position("Robot " + available_bots[bot_num].Get_RobotID() 
                                              + " is here for pickup: ");
        
    }
    else cout << "Technical difficculties.";
    
    cout << "\n\n";
    
    if(available_bots[bot_num].MoveTo(dropoff))
    {
        available_bots[bot_num].Show_Position("Robot " + available_bots[bot_num].Get_RobotID() 
                                              + " has dropped off passenger at: ");
        cout << "\n\n";
        
        cout << "('Y' or 'N') Would you like to tip? ";
        cin >> response;
        switch (toupper(response))
        {
            case 'Y':   cout << "\nEnter tip amount: $";
                        cin >> tip;
                        break;
                        
            case 'N':   tip = 0.00;
                        break;
            
            default:    cout << "\nInvailid respnse. There will be no tip added.";
                        tip = 0.00;              
        }
        
    }
    else cout << "Technical difficculties.";
    
    ride_cost = travel_rate * trip_distance;
    taxes = tax * ride_cost;
    total = ride_cost + taxes + tip;
    
    cout << "\n\n===============================================\n\n";
    
    cout << "Receipt\n\n";
    cout << "Travel rate............ $" << travel_rate << endl;
    cout << "Trip Distance.......... " << trip_distance << " miles" << endl;
    cout << "Ride Cost.............. $" << fixed << setprecision(2) << ride_cost << endl;
    cout << "Tip.................... $" << fixed << setprecision(2) << tip << endl;
    cout << "Taxes.................. $" << fixed << setprecision(2) << taxes << endl;
    cout << "Total.................. $" << fixed << setprecision(2) << total << endl;
    
    cout << "\n\n\n==============End of Bill==========++++=========\n\n\n";
    
    //update ROBOT201 view of current location
    available_bots[bot_num].StartUp(dropoff.xpos, dropoff.ypos);
    
    //clear available vectors
    //available_bots.erase (available_bots.begin(),available_bots.end());
    //available_pickups.erase (available_pickups.begin(),available_pickups.end());
    
}