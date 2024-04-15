

// Checkpoint Events
function onCheckpointEntered( player, checkpoint ){}
function onCheckpointExited( player, checkpoint ){}


//Object Events
function onObjectShot( object, player, weapon ){}
function onObjectBump( object, player ){}


//Pickup Events
function onPickupClaimPicked( player, pickup ){}
function onPickupPickedUp( player, pickup ){}
function onPickupRespawn( pickup ){}


//Player Events
function onPlayerJoin( player )
{
  local n=0;do{n++;MessagePlayer(" ",player);}while(n<100) // this code displays empty 100 messages for the old chat, which clears the old chat
  loadPlayerData(player.ID,0); // Loading register system when player join
}

function onPlayerPart( player, reason ){saveData(player);}


function onPlayerRequestClass( player, classID, team, skin ){return false;}
function onPlayerRequestSpawn( player ){return false;}

function onPlayerSpawn( player )
{
  player.Pos = player.Pos=Vector(data[player.ID].i,data[player.ID].j,data[player.ID].k); // This code loads player's last saved position and spawn the player at there
  player.Health = data[player.ID].health; // This code loads player's last saved health 
  player.Colour = RGB(255,0,0);
}
function onPlayerDeath( player,reason ){
  GetNearestHospital(player); // This code spawning player at the nearest hospital (Useful when you need to respawn them)
}
function onPlayerKill( killer, player, reason, bodypart ){
  GetNearestHospital(player); // This code spawning player at the nearest hospital (Useful when you need to respawn them)
}
function onPlayerTeamKill( player, killer, reason, bodypart ){
  GetNearestHospital(player); // This code spawning player at the nearest hospital (Useful when you need to respawn them)
}
function onPlayerChat( player, message )
{
 for(local i=0; i<10; i++){MessagePlayer(" ", player);}  // In this server we use different chat system so this code sends 10 empty message to the old chat which clears it
 return false; // This code is closing the old chat
}
function onNewPlayerChat(player,message){
  local aColour = player.Colour, pcolor = format("[#%02X%02X%02X]", aColour.r, aColour.g, aColour.b);
  if(chat[player.ID].muted == true) return false;
  if (chat[player.ID].rep == 3){
    chat[player.ID].muted = true;
   newMessage(pcolor.tolower()+player.Name+" [#ffffff]muted for 15 seconds. Because spamming the chat!");
    NewTimer("UnMuteTimer", 15000, 1, player.ID);
    return false;
  }chat[player.ID].rep +=1;
  if (chat[player.ID].rep == 1){NewTimer("RepTimer", 3000, 1, player.ID);}
  for(local i = 0; i<100; i++){SendDataToClient(i, 2022, pcolor.tolower()+player.Name+": [#ffffff]"+message);}
}
function onPlayerCommand( player, command, arguments ){} // The command event which can be used with old chat panel

function onNewPlayerCommand( player,cmd,params ){
  local aColour = player.Colour, pcolor = format("[#%02X%02X%02X]", aColour.r, aColour.g, aColour.b);
  if (cmd=="admin" && params=="adminpass"){data[player.ID].level=1000; newMessage(pcolor.tolower()+player.Name+" is signed as [#ff0000]admin[#ffffff]!");}
  onVehicleCommands(player,cmd,params); // this function is to use vehicle commands which is on custom vehicle events section
} // The command event which is for new chat!

function onPlayerPM( player, playerTo, message ){}
function onPlayerBeginTyping( player ){}
function onPlayerEndTyping( player ){}
//function onLoginAttempt( playerName, password, ipAddress ){}  // it is not useful for this server

function onPlayerMove( player, lastX, lastY, lastZ, newX, newY, newZ ){}
function onPlayerHealthChange( player, lastHP, newHP ){  if(data[player.ID].immortal==true){player.Health=100;}  }
function onPlayerArmourChange( player, lastArmour, newArmour ){}
function onPlayerWeaponChange( player, oldWep, newWep ){}
function onKeyDown( player, bindID ){}
function onKeyUp( player, bindID ){}
function onPlayerAwayChange( player, newStatus ){}
function onPlayerSpectate( player, target ){}
function onPlayerCrashDump( player, crashReport ){}
function onPlayerNameChange( player, oldName, newName ){}
function onPlayerActionChange( player, oldAction, newAction ){}
function onPlayerStateChange( player, oldState, newState ){}
function onPlayerOnFireChange( player, isOnFireNow ){}
function onPlayerCrouchChange( player, isCrouchingNow ){}
function onPlayerGameKeysChange( player, oldKeys, newKeys ){}


//Server Events
function onServerStart( ){}
function onServerStop( ){}
function onScriptLoad( )
{
  DataBase <- ConnectSQL( "DataBase.db" ); // This database is for 'Registration and Ban System'
  TurkishLetters <- ConnectSQL( "Turkish/Letters.db" ); // This database is for 'Turkish Character Support System'
  data <- array(GetMaxPlayers(), null); // This variable will be useful for you to manage user's game data such as score, money, banstatus etc.
  class userData// This variable is going to be required to use the variable 'data array' 
  {
    logged = false; registered = false; immortal = true; world = 0;
    accountid = 0; name = null; password = null;
    isBanned = false; UID1 = null; UID2 = null; IP = null;
    i = -1511.96; j = -928.754; k = 20.8823; health = 100; 
    skin = 0; level = 0; kills = 0; deaths = 0; cash = 0; bank = 0;
  } 
  class ChatClass{rep = 0;muted = false;} // this is for anti spam system
  chat <- array(GetMaxPlayers(),null); // this array variable is for anti spam system
  // These querysql codes are creating register databases if not exists
  QuerySQL(DataBase, "create table if not exists Account (AccountID NUMERIC DEFAULT 0, name TEXT, password VARCHAR(255))"); // This sql code creates accounts table which has user's name and password
  QuerySQL(DataBase, "create table if not exists BanState (AccountID NUMERIC DEFAULT 0, isBanned BOOLEAN DEFAULT false, UID1 VARCHAR(255), UID2 VARCHAR(255), IP VARCHAR(255))"); // This sql code creates ban table which has user's name and password
  QuerySQL(DataBase, "create table if not exists Position (AccountID NUMERIC DEFAULT 0, i NUMERIC DEFAULT -1511.96, j NUMERIC DEFAULT -928.754, k NUMERIC DEFAULT 20.8823,  health NUMERIC DEFAULT 100)"); // This table is for lastpos system
  QuerySQL(DataBase, "create table if not exists GameStuff (AccountID NUMERIC DEFAULT 0, skin NUMERIC DEFAULT 0, level NUMERIC DEFAULT 0, kills NUMERIC DEFAULT 0, deaths NUMERIC DEFAULT 0, cash NUMERIC DEFAULT 0, bank NUMERIC DEFAULT 0 )"); // This table can be used to save user's level and the other game stuff
  
  // This is for vehicle system
  VehicleDB <- ConnectSQL( "VehicleDB.db" );
  QuerySQL(VehicleDB, "create table if not exists Vehicles (List NUMERIC DEFAULT 0, ID NUMERIC DEFAULT 0,"
                     +"Model NUMERIC DEFAULT 0, World NUMERIC DEFAULT 0,"
                     +"PosX TEXT,PosY TEXT, PosZ TEXT,"
                     +"Col1 TEXT, Col2 TEXT, Angle TEXT,"
                     +"Locked BOOLEAN DEFAULT true,Owner TEXT,Price NUMERIC DEFAULT 0)");
  LoadVehicles();

}
function onScriptUnload( ){}


//Client Events
function onClientScriptData( player )
{
  local int=Stream.ReadInt(), str=Stream.ReadString();
  fundamentalScriptData(player,int,str); // this event is for clear the long codes of the registration and chat system
}

//Sphere Events
function onSphereEntered( player, sphere ){}
function onSphereExited( player, sphere ){}


//Custom Vehicle Events

function onVehicleCommands(player,cmd,text)
{
  if (cmd == "buycar"){
    if (!text){newMessagePlayer("/buycar <id>",player); return false;}
    if (!IsNum(text)){newMessagePlayer("/buycar <id>",player); return false;}
    local vehicle = FindVehicle(text.tointeger())
    if (vehicle){
      local r = QuerySQL(VehicleDB, "SELECT * FROM Vehicles WHERE ID = '" + vehicle.ID + "'");
      if (r){
        local Model =q(r,2).tointeger(),Owner = q(r,11).tostring(),Price = q(r,12).tointeger();
        if (Owner != "null"){newMessagePlayer("This car is owned by "+Owner+" for "+Price+"$", player); return false;}
        if (player.Cash < Price){newMessagePlayer("Your money isn't enough for buy this car", player); return false;}
        QuerySQL( VehicleDB, "UPDATE Vehicles SET Owner='"+player.Name+"' WHERE ID LIKE '" + vehicle.ID + "'" );
        player.Cash -= Price;
        newMessagePlayer("You bought "+GetVehicleNameFromModel( Model )+" with "+vehicle.ID+" ID", player);
      }else{newMessagePlayer("This car isn't available try another vehicle", player);return false;}
    }
  }
  else if (cmd == "sellcar"){
    if (!text){newMessagePlayer("/buycar <id>",player); return false;}
    if (!IsNum(text)){newMessagePlayer("/buycar <id>",player); return false;}
    local vehicle = FindVehicle(text.tointeger())
    if (vehicle){
      local r = QuerySQL(VehicleDB, "SELECT * FROM Vehicles WHERE ID = '" + vehicle.ID + "'");
      if (r){
        local Owner = q(r,11).tostring(),Price = q(r,12).tointeger();
        if (Owner != "null" && Owner != player.Name){newMessagePlayer("This car is owned by "+Owner+" for "+Price+"$", player); return false;}
        if (Owner == "null"){newMessagePlayer("This car isn't yours", player); return false;}
        QuerySQL( VehicleDB, "UPDATE Vehicles SET Owner='"+"null"+"' WHERE ID LIKE '" + vehicle.ID + "'" );
        newMessagePlayer("You sold your vehicle for "+Price*0.5+"$", player);
        player.Cash += Price*0.5;
      }else{newMessagePlayer("This car isn't available try another vehicle", player);return false;}
    }
  }
  else if (cmd == "getcar"){
    if (!text){newMessagePlayer("/getcar <id>",player); return false;}
    if (!IsNum(text)){newMessagePlayer("/getcar <id>",player); return false;}
    local vehicle = FindVehicle(text.tointeger())
    if (vehicle){
      local r = QuerySQL(VehicleDB, "SELECT * FROM Vehicles WHERE ID = '" + vehicle.ID + "'");
      if (r){
        local Owner = q(r,11).tostring();
        local Price = q(r,12).tointeger();
        if (Owner != "null" && Owner != player.Name||Owner == "null"){newMessagePlayer("This car isn't yours", player); return false;}
        vehicle.Pos = Vector(player.Pos.x+2, player.Pos.y, player.Pos.z);
        newMessagePlayer("You teleported your vehicle to yourself", player);
      }else{newMessagePlayer("This car isn't available try another vehicle", player);return false;}
    }
  }
  else if (cmd == "lockcar"){
    if (!text){newMessagePlayer("/lockcar <id>",player); return false;}
    if (!IsNum(text)){newMessagePlayer("/lockcar <id>",player); return false;}
    local vehicle = FindVehicle(text.tointeger())
    if (vehicle){
      local r = QuerySQL(VehicleDB, "SELECT * FROM Vehicles WHERE ID = '" + vehicle.ID + "'");
        if (r){local Owner = q(r,11).tostring(),Price = q(r,12).tointeger();
          if (Owner != "null" && Owner != player.Name||Owner == "null"){newMessagePlayer("This car isn't yours", player); return false;}
          QuerySQL( VehicleDB, "UPDATE Vehicles SET Locked='"+"true"+"' WHERE ID LIKE '" + vehicle.ID + "'" );
          newMessagePlayer("You locked your car", player);
        }else{
          newMessagePlayer("This car isn't available try another vehicle", player);
          return false;
        }
    }
  }
  else if (cmd == "unlockcar"){
    if (!text){newMessagePlayer("/unlockcar <id>",player); return false;}
    if (!IsNum(text)){newMessagePlayer("/unlockcar <id>",player); return false;}
    local vehicle = FindVehicle(text.tointeger())
    if (vehicle){
      local r = QuerySQL(VehicleDB, "SELECT * FROM Vehicles WHERE ID = '" + vehicle.ID + "'");
      if (r){
        local Owner = q(r,11).tostring(), Price = q(r,12).tointeger();
        if (Owner != "null" && Owner != player.Name||Owner == "null"){newMessagePlayer("This car isn't yours", player); return false;}
        QuerySQL( VehicleDB, "UPDATE Vehicles SET Locked='"+"false"+"' WHERE ID LIKE '" + vehicle.ID + "'" );
        newMessagePlayer("You unlocked your car", player);
      }else{newMessagePlayer("This car isn't available try another vehicle", player);return false;}
    }
  }
  else if (cmd == "mycars"){
    local cars = "";
    for(local i = 0; i<500; i++){local r = QuerySQL(VehicleDB, "SELECT * FROM Vehicles WHERE List = '" + i + "'");
      if (r){
        local Owner = q(r,11).tostring(),ID = q(r,1).tointeger(),Model = q(r,2).tointeger();
        if (Owner == player.Name){
          if (cars !=""){
            cars = cars+", "+GetVehicleNameFromModel( Model )+"("+ID+")";
          }
          if (cars == ""){
            cars = ""+GetVehicleNameFromModel( Model )+"("+ID+")";
          }
        }
      }
    }
    local t = QuerySQL(VehicleDB, "SELECT * FROM Vehicles WHERE Owner = '" + player.Name + "'");
    if (t){newMessagePlayer("Your cars: " +cars, player);}
    else{newMessagePlayer("You haven't got any car", player);return false;}
  }
  else{
    if (data[player.ID].level == 1000){
      onVehicleAdminCommands( player, cmd, text );
    }
  }
}
function onVehicleAdminCommands( player, cmd, text )
{
  if (cmd == "addcar"){
    if (!text){newMessagePlayer("/addcar <world> <model> <col1> <col2> <price>",player); return false;}
    if (!GetTok( text, " ", 1 )||!GetTok( text, " ", 2 )||!GetTok( text, " ", 3 )||!GetTok( text, " ", 4 )||!GetTok( text, " ", 5 )||GetTok( text, " ", 6 )){newMessagePlayer("/addcar <world> <model> <col1> <col2> <price>",player); return false;}
    if (!IsNum(GetTok( text, " ", 1 ))||!IsNum(GetTok( text, " ", 2 ))||!IsNum(GetTok( text, " ", 3 ))||!(IsNum(GetTok( text, " ", 4 )))||!IsNum(GetTok( text, " ", 5 ))){newMessagePlayer("/addcar <world> <model> <col1> <col2> <price>",player); return false;}
    local lastlist = 0,world = GetTok( text, " ", 1 ).tointeger(),model = GetTok( text, " ", 2 ).tointeger(),col1 = GetTok( text, " ", 3 ).tointeger(),col2 = GetTok( text, " ", 4 ).tointeger(),price = GetTok( text, " ", 5 ).tointeger(),
    veh = CreateVehicle( model, world, Vector(player.Pos.x,player.Pos.y,player.Pos.z), player.Angle, col1 ,col2 ),
    vehID= GetVehicleCount();
    for(local i = 0; i<500; i++){local r = QuerySQL(VehicleDB, "SELECT * FROM Vehicles WHERE List = '" + i + "'");
      if (r){lastlist++;}
    }
    QuerySQL(VehicleDB, "INSERT INTO Vehicles ( List, ID, Model , World, PosX, PosY, PosZ, Col1, Col2, Angle, Locked,Owner,Price) VALUES ( '" + lastlist + "','" + vehID + "','" + model + "','" + world + "','" + player.Pos.x + "','" + player.Pos.y  + "','" + player.Pos.z  + "','" + col1 + "','" + col2 + "','" + player.Angle + "','" + true + "','" + "null" + "','" + price + "' )");
  }
  if (cmd == "removecar"){
    if (!text){newMessagePlayer("/removecar <vehicleID>",player); return false;}
    if (!GetTok( text, " ", 1 )||!IsNum(GetTok( text, " ", 1 )) || GetTok( text, " ", 2 )){newMessagePlayer("/removecar <vehicleID>",player); return false;}
    local vehicle = FindVehicle(GetTok( text, " ", 1 ).tointeger());
    if (!vehicle){newMessagePlayer("This car isn't available try another vehicle", player); return false;}
    local lastlist = 0,List = 0,i = 0;
    for(i = 0; i<500; i++){local a = QuerySQL(VehicleDB, "SELECT * FROM Vehicles WHERE List = '" + i + "'");
      if (a){lastlist++;}
    }
    local b = QuerySQL(VehicleDB, "SELECT * FROM Vehicles WHERE ID = '" + vehicle.ID + "'");
    if (b){List = GetSQLColumnData(b, 0).tointeger();
      QuerySQL( VehicleDB, "DELETE FROM Vehicles WHERE ID='"+vehicle.ID+"'" );
      vehicle.Delete();
    }
    for(i = List+1; i<lastlist; i++){local c = QuerySQL(VehicleDB, "SELECT * FROM Vehicles WHERE List = '" + i + "'");
      if (c){
        local newList = GetSQLColumnData(c, 0).tointeger()-1;
        QuerySQL( VehicleDB, "UPDATE Vehicles SET List='"+newList+"' WHERE List LIKE '" + i + "'" );
      }ReloadVehicles();
    }
  }
  if (cmd == "changecol")
  {
    if (!text){newMessagePlayer("/changecol <vehicle id> <col1 id> <col2 id>",player); return false;}
    if(!GetTok( text, " ", 1 )||!GetTok( text, " ", 2 )||!GetTok( text, " ", 3 )||GetTok(text, " ", 4)){newMessagePlayer("/changecol <vehicle id> <col1 id> <col2 id>",player); return false;}
    if(!IsNum(GetTok( text, " ", 1 ))||!IsNum(GetTok( text, " ", 2 ))||!IsNum(GetTok( text, " ", 3 ))){newMessagePlayer("/changecol <vehicle id> <col1 id> <col2 id>",player); return false;}
    local vehicle = FindVehicle(GetTok( text, " ", 1 ).tointeger())
    local col1 = GetTok( text, " ", 2 ).tointeger(),col2 = GetTok( text, " ", 3 ).tointeger();
    if (vehicle){
      local r = QuerySQL(VehicleDB, "SELECT * FROM Vehicles WHERE ID = '" + vehicle.ID + "'");
      if (r){
        QuerySQL( VehicleDB, "UPDATE Vehicles SET Col1='"+col1+"', Col2 = '"+col2+"' WHERE ID LIKE '" + vehicle.ID + "'" );
        newMessagePlayer("Vehicle ID:"+vehicle.ID+"'s color has been changed with col1:"+col1+", col2: "+col2+"", player);
        vehicle.Colour1 = col1
        vehicle.Colour2 = col2
      }else{newMessagePlayer("This car isn't available try another vehicle", player);return false;}
    }
  }
  if (cmd == "changepos"){
    if (!text){newMessagePlayer("/changepos <vehicle id>",player); return false;}
    if (!GetTok( text, " ", 1 )||!IsNum(GetTok(text, " ", 1))||GetTok( text, " ", 2 )){newMessagePlayer("/changepos <vehicle id>",player); return false;}
    local vehicle = FindVehicle(GetTok( text, " ", 1 ).tointeger()),px = player.Pos.x.tostring(),py = player.Pos.y.tostring(),pz = player.Pos.z.tostring(),angle = asin(vehicle.Rotation.z)*2;
    if (!vehicle){return false;}
    local r = QuerySQL(VehicleDB, "SELECT * FROM Vehicles WHERE ID = '" + vehicle.ID + "'");
    if (r){QuerySQL( VehicleDB, "UPDATE Vehicles SET PosX='"+px+"', PosY = '"+py+"', PosZ = '"+pz+"', Angle = '"+angle+"' WHERE ID LIKE '" + vehicle.ID + "'" );
      newMessagePlayer("Vehicle ID:"+vehicle.ID+"'s position has been changed with position:"+px+", "+py+", "+pz+"", player);
    }else{newMessagePlayer("This car isn't available try another vehicle", player);return false;}
    ReloadVehicles();
  }
}

function ReloadVehicles(){
  for(local i = 0; i<500; i++){
    local r = QuerySQL(VehicleDB, "SELECT * FROM Vehicles WHERE List = '" + i + "'");
    if (r){
      local veh = FindVehicle(q(r,1).tointeger()); if (veh){veh.Delete();} if(i==500){}
    }
  }LoadVehicles();
}
function LoadVehicles(){
  for(local i = 0; i<500; i++){local r = QuerySQL(VehicleDB, "SELECT * FROM Vehicles WHERE List = '" + i + "'");
    if (r){
      local Model = q(r,2).tointeger(), PosX = q(r,4).tofloat(), PosY = q(r,5).tofloat(), PosZ = q(r,6).tofloat(), Col1 = q(r,7).tointeger(), Col2 = q(r,8).tointeger(), Angle = q(r,9).tofloat();
      CreateVehicle( Model, 1, Vector(PosX,PosY,PosZ), Angle, Col1 ,Col2 )
      local newID = GetVehicleCount();
      QuerySQL( VehicleDB, "UPDATE Vehicles SET ID='"+newID+"' WHERE List LIKE '" + i + "'" );
    }
  }
}

//Vehicle Events

function onPlayerEnteringVehicle( player, vehicle, door )
{
  local r = QuerySQL(VehicleDB, "SELECT * FROM Vehicles WHERE ID = '" + vehicle.ID + "'")
  if (r){local Locked = q(r,10).tostring();
    if (Locked == "true"){
      local Owner = q(r,11).tostring();
      local Price = q(r,12).tointeger();
      if(Owner != "null"){newMessagePlayer("This car locked by "+Owner,player);}
      if(Owner == "null"){newMessagePlayer("You haven't got keys. Use /buycar "+vehicle.ID,player);}
      return false;
    }else{return true;}
  }else{return true;}
}
function onPlayerEnterVehicle( player, vehicle, door )
{
  local r = QuerySQL(VehicleDB, "SELECT * FROM Vehicles WHERE ID = '" + vehicle.ID + "'")
  if (r){ local Owner=q(r,11).tostring(), Price=q(r,12).tointeger();
    if (Owner != "null"){newMessagePlayer("This car is owned by "+Owner+" for "+Price+"$",player);}
    if (Owner == "null"){newMessagePlayer("This car is for sale "+Price+"$",player);}
  }
}
function onPlayerExitVehicle( player, vehicle ){}
function onVehicleExplode( vehicle ){}
function onVehicleRespawn( vehicle ){}
function onVehicleHealthChange( vehicle, oldHP, newHP ){}
function onVehicleMove( vehicle, lastX, lastY, lastZ, newX, newY, newZ ){}






// Required For Register And Chat Systems

function fundamentalScriptData(player,int,str)
{
  
  // this checks if the data from client side is came for login request or register request, it is important!
  if (  data[player.ID].logged  ==  false  ) 
  {  
    local state = ""; 
    if (int == 1) {  state="register";  } 
    else if (int == 2) {  state="login";  } 
    loginHandler(player, state, str); 
    return false;
  } 
  //

  // this code is for the new chat system which opens with 'Y' key
  local aColour = player.Colour, pcolor = format("[#%02X%02X%02X]", aColour.r, aColour.g, aColour.b);
  if(int==2022)
  {

    // This code is for the new command system which is defined function onNewPlayerCommand(player,cmd,params) it works just like the old one, difference is the new chat
    if ( isStrContain("/",str) ){
      if ( str.find("/")!=0 && isOnlyContain( " ", str.slice(0, str.find("/") ) ) == false ){}
      else{
        local cmd = "", params = "";
        if ( str.find("/")!=0 && isOnlyContain( " ", str.slice(0, str.find("/") ) ) ){str=str.slice(str.find("/"),str.len());}
        if (isStrContain(" ",str))
        {
          cmd = GetTok(str," ",1); cmd = cmd.slice(1,cmd.len());
          if (str.find(" ")!=str.len()-1){ params = str.slice( str.find(" ")+1, str.len() ); }

        }else if(!isStrContain(" ",str)){  cmd=str.slice(1,str.len());  }
        onNewPlayerCommand(player,cmd,params); return false;
      }
    }
    //
    onNewPlayerChat(player,str);
  }
  //

}

function lRequest(p,s){p=FindPlayer(p); if(p){SendDataToClient(p.ID,1,s);}}
function LoginScreen(p){p=FindPlayer(p); 
  if(p){
    p.Spawn();
  }
}
// Custom Player Events
function loadPlayerData(p,n)
{
  local player = GetPlayer(p);
    if (n==0)
    {
        data[p] = userData(); // This loads data array variable for every user
        chat[player.ID] = ChatClass(); // This loads data for spam system for every user
        NewTimer("loadPlayerData", 1000, 1,p,1); // We load the data with 1second delay
        NewTimer("LoginScreen", 2000, 1,p);
    }
    else if (n==1)
    {
        // This codes reads data from database and change data[] array variable by those values 
        local qb = QuerySQL(DataBase, format( "SELECT * FROM BanState WHERE UID1 = '%s' OR UID2 = '%s' OR IP = '%s'", player.UniqueID, player.UniqueID2, player.IP ) );
        if (!qb){NewTimer("lRequest", 3000, 1,p,"register"); return false;}
        data[p].accountid = q(qb,0); data[p].isBanned = q(qb,1); data[p].UID1 = q(qb,2);  data[p].UID2 = q(qb,3);  data[p].IP = q(qb,4); 
        // This codes kicks player automatically if the user is banned from server
        if(data[p].isBanned==true){ 
            local i = 0;
            do{
                i++;
                newMessagePlayer("[#ff0000]You have been banned from this server");
            }while(i<10)
            newMessage(data[p].name+" is kicked."); 
            KickPlayer(player); 
        }
        // 
        local q1 = QuerySQL(DataBase, format( "SELECT * FROM Account WHERE AccountID = '%s'", data[p].accountid.tostring() ) ); 
        local q2 = QuerySQL(DataBase, format( "SELECT * FROM Position WHERE AccountID = '%s'", data[p].accountid.tostring() ) ); 
        local q3 = QuerySQL(DataBase, format( "SELECT * FROM GameStuff WHERE AccountID = '%s'", data[p].accountid.tostring() ) ); 
        data[p].name = q(q1,1); data[p].password = q(q1,2); 
        data[p].i = q(q2,1); data[p].j = q(q2,2); data[p].k = q(q2,3); data[p].health = q(q2,4); 
        data[p].skin = q(q3,1); data[p].level = q(q3,2); data[p].kills = q(q3,3); data[p].deaths = q(q3,4); data[p].cash = q(q3,5); data[p].bank = q(q3,6);
        // 
        data[p].registered = true; data[p].logged = true; data[p].immortal = false; // this array variables are for show the login and register state true  
    }
}

function saveData(player){local p=player.ID;
  local q1 = QuerySQL(DataBase, format( "SELECT * FROM Account WHERE AccountID = '%s'", data[p].accountid.tostring() ) ); 
  local q2 = QuerySQL(DataBase, format( "SELECT * FROM BanState WHERE AccountID = '%s'", data[p].accountid.tostring() ) ); 
  local q3 = QuerySQL(DataBase, format( "SELECT * FROM Position WHERE AccountID = '%s'", data[p].accountid.tostring() ) ); 
  local q4 = QuerySQL(DataBase, format( "SELECT * FROM GameStuff WHERE AccountID = '%s'", data[p].accountid.tostring() ) ); 
  if (q1&&q2&&q3&&q4){
    data[p].i=player.Pos.x; data[p].j=player.Pos.y; data[p].k=player.Pos.z; data[p].health=player.Health;
    QuerySQL( DataBase, "UPDATE Account SET AccountID='"+data[p].accountid+"', name='"+data[p].password+"',password='"+data[p].name+"'" );
    QuerySQL( DataBase, "UPDATE BanState SET AccountID='"+data[p].accountid+"', isBanned='"+data[p].isBanned+"',UID1='"+ data[p].UID1+ "',UID2='"+data[p].UID2+"', IP='"+data[p].IP+"'" );
    QuerySQL( DataBase, "UPDATE Position SET AccountID='"+data[p].accountid+"',i='"+data[p].i+"',j='"+data[p].j+"',k='"+data[p].k+"',health='"+data[p].health+"'" );
    QuerySQL( DataBase, "UPDATE GameStuff SET AccountID='"+data[p].accountid+"',skin='"+data[p].skin+"',level='"+data[p].level+"',kills='"+data[p].kills+"',deaths='"+data[p].deaths+"',cash='"+data[p].cash+"',bank='"+data[p].bank+"'" );
  }
}

function loginHandler(player, state, psswrd)
{
    local p=player.ID; // this is used for shorten the code (we can write 'p' instead of 'player.ID' by using this code)
    if (state == "register")
    { 
        psswrd = SHA256(psswrd); // this is encryption for user's password, kind of a protection for them
        // this querysql codes are for the first time inputing the values into the database 
       
        data[p].accountid = Random(1000, 2000); data[p].name = player.Name; data[p].password = psswrd;
        data[p].isBanned = false; data[p].UID1 = player.UniqueID; data[p].UID2 = player.UniqueID2; data[p].IP = player.IP;

        QuerySQL(DataBase, "INSERT INTO BanState ( AccountID, isBanned, UID1, UID2, IP ) VALUES('"+ data[p].accountid +"','"+ data[p].isBanned +"','"+ data[p].UID1+"','"+ data[p].UID2+"','"+ data[p].IP+"')");
        QuerySQL(DataBase, "INSERT INTO Account ( AccountID, name, password ) VALUES('"+ data[p].accountid +"','"+ data[p].name +"','"+ psswrd +"')");
        QuerySQL(DataBase, "INSERT INTO Position ( AccountID, i, j, k, health ) VALUES('"+ data[p].accountid +"','"+ data[p].i +"','"+ data[p].j+"','"+ data[p].k+"','"+ data[p].health+"')");
        QuerySQL(DataBase, "INSERT INTO GameStuff ( AccountID, skin, level, kills, deaths, cash, bank ) VALUES('"+ data[p].accountid +"','"+ data[p].skin +"','"+ data[p].level+"','"+ data[p].kills+"','"+ data[p].deaths+"','"+ data[p].cash+"','"+ data[p].bank+"')");
        
        data[p].registered = true; data[p].logged = true; data[p].immortal = false;// this array values are used for state the login and register status
        SendDataToClient(p, 2, ""); // this code sends id to close register panel code to client
    }
    if (state == "login")
    {
        if (data[p].password==SHA256(psswrd))
        {
            data[p].logged=true; data[p].immortal = false;// this array value is used for state the login status
            SendDataToClient(p, 2, ""); // this code sends id to close register panel code to client
        }
        else
        {
            SendDataToClient(p,3,"Wrong Password"); // this sends client a code which says 'Wrong password' to user
        }
    }
}
function q(r, n)
{
    return GetSQLColumnData(r,n);
}


// Required Custom Functions (These functions are used to make code much more easier most of them are required for fundamental things) 

function SendDataToClient(p,i,s){p=FindPlayer(p);if(p){Stream.StartWrite();Stream.WriteInt(i);}if(s!=null){Stream.WriteString(s);}Stream.SendStream(p);}
function Random(from, to) return (rand()*(to+1-from)) / (RAND_MAX+1)+from;

function letterSupportTurkish(string){
  local x=QuerySQL(TurkishLetters, format( "SELECT * FROM Letters"));
  local letters = ["Ç,3,4 ","Ğ,8,9","İ,11,12","Ö,18,19","Ş,22,23","Ü,25,26","ç,32,33","ğ,37,38","ı,39,40","ö,47,48","ş,51,52","ü,54,55"], i=0;
  do{
    local searchfor = GetTok(letters[i],",",1).tostring(),s1=GetTok(letters[i],",",2).tointeger(),s2=GetTok(letters[i],",",3).tointeger();
	  string = FindAndReplace(string,searchfor,q(x,0).slice(s1,s2));
    i=i+1;
  }while(i<12)
  return string;
}
function newMessage(message)
{
    message = letterSupportTurkish(message);
    for(local i = 0; i<100; i++){SendDataToClient(i, 2022,"[#ffffff]"+message);}
}
function newMessagePlayer(message,player)
{
  message = letterSupportTurkish(message);
  SendDataToClient(player.ID, 2022,"[#ffffff]"+message);
}

function GetNearestHospital(player){local X=player.Pos.x, Y=player.Pos.y;
  local hosp1 = DistanceFromPoint( X,Y, -886.074,-470.278).tointeger(),hosp2 = DistanceFromPoint( X,Y, 467.763,697.68).tointeger(),hosp3 = DistanceFromPoint( X,Y, -783.051,1141.83).tointeger(),hosp4 = DistanceFromPoint( X,Y, -135.137,-981.579).tointeger();
  if (hosp1 < hosp2 && hosp1 < hosp3 && hosp1 < hosp4){data[ player.ID ].hospital = Vector(-886.074,-470.278,13.1109);}
 else if (hosp2 < hosp1 && hosp2 < hosp3 && hosp2 < hosp4){data[ player.ID ].hospital = Vector(467.763,697.68,11.7033);}
 else if (hosp3 < hosp1 && hosp3 < hosp2 && hosp3 < hosp4){data[ player.ID ].hospital = Vector(-783.051,1141.83,12.4111);}
 else if (hosp4 < hosp1 && hosp4 < hosp2 && hosp4 < hosp3){data[ player.ID ].hospital = Vector(-135.137,-981.579,10.4634);}
}

function GetPlayer(plr)
{
    if ( IsNum( plr.tostring() ) )
    {
        plr = FindPlayer( plr.tointeger() ); 
        if ( plr ){ return plr; } 
        else { return false; }
    }
    else
    {
        plr = FindPlayer( plr ); 
        if ( plr ){ return plr; }
        else {  return false;  }
    }
}

function GetTok(string, separator, n)
{
    local m = vargv.len() > 0 ? vargv[0] : n,tokenized = split(string, separator),text = "";
    if (n > tokenized.len() || n < 1)
    {
        return null;
    }
    for (; n <= m; n++){
        text += text == "" ? tokenized[n-1] : separator + tokenized[n-1];
    } 
    return text;
}

function NumTok(string, separator)
{
    local tokenized = split( string, separator ); 
    return tokenized.len();
}

function isOnlyContain(string,str){
  if (string.len()<1||str.len()<1){return null;}
  local n=0;
  do{
    if ( str.slice(n,n+1) != string  ){
      return false;
      n = str.len();
    }
    n++;
  }while( n < str.len()-1 )
  if ( n == str.len()-1 ) { return true; }
}

function isStrContain(str,string)
{
    if(string.find(str)!= null)
    {
        return true;
    }
    else
    {
        return false;
    }
}
function FindAndReplace(str,fstr,replace)
{
    if ( !isStrContain(fstr,str) || fstr == str ){  return str;  }
    else
    {
      do
      {
          local pre = "", next = "", a = str.len(), b = str.find( fstr ), c = fstr.len();
          if ( b != 0 ) {  pre = str.slice( 0, b );  } if ( b != a-1 ) {  next = str.slice( b+c, a );  }
          str = format("%s%s%s", pre, replace, next);
      } while ( isStrContain ( fstr, str ) == true )
      if ( isStrContain ( fstr, str ) == false ) {  return str;  }
    }
}

function hasSpecialChar(str){
  local alphabet="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789",n=0;
  do{
    if ( isStrContain( str.slice(n,n+1), alphabet ) == false ){
      return true;
      n = str.len();
    }
    n++;
  }while( n < str.len()-1 )
  if ( n == str.len()-1 ) { return false; }
}

function RepTimer(p){p=FindPlayer(p);if(p){chat[p.ID].rep = 0;}}
function UnMuteTimer(p){p=FindPlayer(p);if(p){local aColour = p.Colour, pcolor = format("[#%02X%02X%02X]", aColour.r, aColour.g, aColour.b); newMessage(pcolor.tolower()+p.Name+" [#ffffff]unmuted. Please don't spam chat.");chat[p.ID].rep = 0;chat[p.ID].muted = false;}}
