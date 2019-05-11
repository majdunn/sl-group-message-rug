
// collision list
list users;
string user;

// notecard reader 
integer line;
string configurationFile = "config";
key readLineId;
string messageInGroup;
string messageNoGroup;
string messageSetText;

init()
{
    llSay(0, "Setting up the group joiner...");
    // reset configuration values to default
    messageInGroup = "";
    messageNoGroup = "";
    messageSetText = "";
    
    // make sure the file exists and is a notecard

    if(llGetInventoryType(configurationFile) != INVENTORY_NOTECARD)
    {
        // notify owner of missing file
        llOwnerSay("Missing inventory notecard: " + configurationFile);
        return; // don't do anything else
    }

    // initialize to start reading from first line
    line = 0;
    // read the first line
    readLineId = llGetNotecardLine(configurationFile, line++);
    
}

processConfiguration(string data)
{
    // if we are at the end of the file
    if(data == EOF)
    {
        // notify the owner
        llOwnerSay("We are done reading the configuration");
        // notify what was read
        llOwnerSay("The in group message is: " + messageInGroup);
        llOwnerSay("The no group tag message is: " + messageNoGroup);
        llOwnerSay("The floating text is: " + messageSetText);
        llSetText(messageSetText, <1.0, 1.0, 1.0>, 1.0);

        // do not do anything else
        return;
    }
    // if we are not working with a blank line
    if(data != "")
    {
        // if the line does not begin with a comment
        if(llSubStringIndex(data, "#") != 0)
        {
            // find first equal sign
            integer i = llSubStringIndex(data, "=");
            // if line contains equal sign
            if(i != -1)
            {
                string name = llGetSubString(data, 0, i - 1); // get name of name/value pair
                string value = llGetSubString(data, i + 1, -1); // get value of name/value pair
                
                list temp = llParseString2List(name, [" "], []); // trim name
                name = llDumpList2String(temp, " "); // set name variable
                name = llToLower(name); // make name lowercase (case insensitive)
                
                temp = llParseString2List(value, [" "], []); // trim value
                value = llDumpList2String(temp, " ");
                
                // variables from notecard
                if(name == "in group message")
                messageInGroup = value;
                
                else if(name == "not in group message")
                messageNoGroup = value;
                
                else if(name == "floating text")
                messageSetText = value;
                
                else // unknown name
                llOwnerSay("Unknown configuration value: " + name + " on line " + (string)line);
            }
            else  // line does not contain equal sign
            {
                llOwnerSay("Configuration could not be read on line " + (string)line);
            }
        }
    }
    // read the next line
    readLineId = llGetNotecardLine(configurationFile, line++);
}

default
{
    state_entry()
    {
        init();
    }

    on_rez(integer start_param)
    {
        init();
    }

    changed(integer change)
    {
        if(change & CHANGED_INVENTORY) init();
        else if(change & CHANGED_OWNER) init();
    }
    
    dataserver(key request_id, string data)
    {
        if(request_id == readLineId)
        processConfiguration(data);
    }
    
    // check for an avatar colliding with the prim.
    collision_start(integer num_detected)   
    {
        user = llDetectedName(0);
        if (llListFindList(users,[user]) == -1) // look at the list, if the name is not there,
        {
            if (llDetectedGroup(0) ) // if avatar has the same active group tag
            {
                llInstantMessage( llDetectedKey(0), messageInGroup);
            }
            else // if group is not active
            {
                llInstantMessage( llDetectedKey(0), messageNoGroup);
            }
            users += user; // add the users name to a list so they only get the message once.
            llSetTimerEvent(600); // change the number for the number of seconds before clearing the list.
        }
    }
    
    timer()
    {
        llSetTimerEvent(0); // turn the timer off
        users = []; // clear the list
    }
}

// MIT LICENSE
// Copyright (c) 2014, MJ Dunn <mjdunnonline@gmail.com>