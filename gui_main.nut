
function Script::ScriptProcess(){
  Timer.Process();
}

Timer <- {
 Timers = {}

 function Create(environment, listener, interval, repeat, ...)
 {
  // Prepare the arguments pack
  vargv.insert(0, environment);

  // Store timer information into a table
  local TimerInfo = {
   Environment = environment,
   Listener = listener,
   Interval = interval,
   Repeat = repeat,
   Args = vargv,
   LastCall = Script.GetTicks(),
   CallCount = 0
  };

  local hash = split(TimerInfo.tostring(), ":")[1].slice(3, -1).tointeger(16);

  // Store the timer information
  Timers.rawset(hash, TimerInfo);

  // Return the hash that identifies this timer
  return hash;
 }

 function Destroy(hash)
 {
  // See if the specified timer exists
  if (Timers.rawin(hash))
  {
   // Remove the timer information
   Timers.rawdelete(hash);
  }
 }

 function Exists(hash)
 {
  // See if the specified timer exists
  return Timers.rawin(hash);
 }

 function Fetch(hash)
 {
  // Return the timer information
  return Timers.rawget(hash);
 }

 function Clear()
 {
  // Clear existing timers
  Timers.clear();
 }

 function Process()
 {
  local CurrTime = Script.GetTicks();
  foreach (hash, tm in Timers)
  {
   if (tm != null)
   {
    if (CurrTime - tm.LastCall >= tm.Interval)
    {
     tm.CallCount++;
     tm.LastCall = CurrTime;

     tm.Listener.pacall(tm.Args);

     if (tm.Repeat != 0 && tm.CallCount >= tm.Repeat)
      Timers.rawdelete(hash);
    }
   }
  }
 }
};

// ============================================================================================

local sX = GUI.GetScreenSize().X,sY = GUI.GetScreenSize().Y;
chatbox <-{Box = null EditBox = null}

function Script::ScriptLoad(){
  createChatBox();
}

rl <-{ Window = null nEditBox = null pEditBox = null errLab = null logButton = null nLab = null pLab = null}
function Server::ServerData( stream ){
 local readint=stream.ReadInt( ),readstr=stream.ReadString( );
 switch(readint.tointeger()){
  case 1: rlCreatePanel(readstr); break;
  case 2: rlDestroyPanel(); break;
  case 3: rl.errLab.Text = readstr; break;
  case 2022: chatProcess(readstr); break;
 }
}
function GUI::ElementRelease( element, mouseX, mouseY ){
  if (element == rl.logButton){GUI.InputReturn(rl.pEditBox);}
}

function GUI::InputReturn( editbox ){ 
    if (editbox == chatbox.EditBox){
      if (chatbox.EditBox.Text == "" || chatbox.EditBox.Text == " " || chatbox.EditBox.Text == " " ){
        chatbox.EditBox = null;
      }else{
        if (chatbox.EditBox.Text.len() < 97){
          SendDataToServer(chatbox.EditBox.Text, 2022);
        }chatbox.EditBox = null;
      }         
  }
  else if (editbox == rl.pEditBox){
    local plr = World.FindLocalPlayer()
    if (rl.nEditBox.Text != plr.Name){
      rl.errLab = null;
      rl.errLab = GUILabel(VectorScreen(sX*0.2, sY*0.2), Colour(200, 200, 200), "");
      rl.errLab.FontSize = sX*0.008;
      rl.Window.AddChild(rl.errLab);
      rl.errLab.Text = "Wrong username";
      return false;
    }
    if (editbox.Text.len() < 3 || editbox.Text.len() > 17){
      rl.errLab = null;
      rl.errLab = GUILabel(VectorScreen(sX*0.1, sY*0.2), Colour(200, 200, 200), "");
      rl.errLab.FontSize = sX*0.008;
      rl.Window.AddChild(rl.errLab);
      rl.errLab.Text = "Your password must be 4-16 characters in length"; return false;
    }
    if (rl.logButton.Text == "REGISTER") {SendDataToServer(rl.pEditBox.Text, 1);}
    if (rl.logButton.Text == "LOGIN") {SendDataToServer(rl.pEditBox.Text, 2);}
  }
}

function SendDataToServer(s, i){local msg=Stream();msg.WriteInt(i.tointeger());msg.WriteString(s);Server.SendData(msg);}



function rlCreatePanel(stream){
  local text = stream.toupper(),plr = World.FindLocalPlayer()
   
  rl.Window = GUIMemobox(VectorScreen( sX*0.35 , sY*0.34 ), VectorScreen(sX*0.29, sY*0.25), Colour(121, 221, 225, 200) )
  rl.errLab = GUILabel(VectorScreen(sX*0.2, sY*0.2), Colour(225, 20, 20), "");
  rl.errLab.FontSize = sX*0.008;
  rl.Window.AddChild(rl.errLab);

  rl.nLab = GUILabel(VectorScreen(sX*0.114, sY*0.026), Colour(255, 255, 255), "User Name");
  rl.nLab.FontSize = sX*0.008;
  rl.Window.AddChild(rl.nLab);
  rl.nEditBox = GUIEditbox(VectorScreen(sX*0.082, sY*0.05), VectorScreen(sX*0.12, sY*0.035), Colour(255, 255, 255, 190), plr.Name);
  rl.nEditBox.FontSize = sX*0.01041666;
  rl.nEditBox.TextColour = Colour(0, 0, 0, 255);
  rl.Window.AddChild(rl.nEditBox);

  rl.pLab = GUILabel(VectorScreen(sX*0.114, sY*0.09), Colour(255, 255, 255), "Password");
  rl.pLab.FontSize = sX*0.008;
  rl.Window.AddChild(rl.pLab);
  rl.pEditBox = GUIEditbox(VectorScreen(sX*0.082, sY*0.114), VectorScreen(sX*0.12, sY*0.035), Colour(255, 255, 255, 190), "", GUI_FLAG_EDITBOX_MASKINPUT);
  rl.pEditBox.TextColour = Colour(0, 0, 0, 255);
  rl.pEditBox.FontSize = sX*0.01041666;
  rl.Window.AddChild(rl.pEditBox);

  rl.logButton = GUIButton(VectorScreen(sX*0.092, sY*0.162), VectorScreen(sX*0.095, sY*0.03), Colour(225, 122, 147), ""+text+"" );
  rl.logButton.TextColour = Colour(255,255,255);
  rl.logButton.FontFlags = GUI_FFLAG_BOLD;
  rl.Window.AddChild(rl.logButton);

  ::Logo <- GUISprite("Logo.png", VectorScreen(sX*0.395 , sY*0.21 ));
  ::Logo.Size = VectorScreen(sX*0.18, sY*0.13);
  ::Logo.Alpha = 255;

  GUI.SetMouseEnabled(true);
}
function rlDestroyPanel(){rl.logButton=null;rl.nEditBox=null;rl.pEditBox=null;rl.errLab=null;rl.Window=null;::Logo<-null;GUI.SetMouseEnabled(false);}

chat_key <- KeyBind( 0x59 );
function KeyBind::OnDown(key){
  if (key == chat_key){
    if(!chatbox.EditBox){
      createChatEditBox();
    }
  }
}
function VScreen(pos_x, pos_y){//Credits goes to Doom_Kill3R for this function
 local
     screenSize = GUI.GetScreenSize( ),
     x = floor( pos_x * screenSize.X / 1920 ),
     y = floor( pos_y * screenSize.Y / 1080 );
  return VectorScreen( x, y );
}

function createChatBox(){
  chatbox.Box = GUIMemobox(VScreen( 10 , 25 ), VScreen(1000, 400), Colour(0, 0, 0, 255), GUI_FLAG_MEMOBOX_TOPBOTTOM | GUI_FLAG_VISIBLE | GUI_FLAG_TEXT_TAGS);
  chatbox.Box.RemoveFlags( GUI_FLAG_BACKGROUND | GUI_FLAG_BORDER );
  chatbox.Box.FontSize = floor( 17 * GUI.GetScreenSize( ).Y / 1080 );
  chatbox.Box.FontName = "TR Tahoma Bold"
  chatbox.Box.FontFlags = GUI_FFLAG_OUTLINE;
  chatbox.Box.LineHeight = 0;
}

function createChatEditBox(){
    chatbox.EditBox = GUIEditbox(VScreen( 15, 370 ), VScreen( 900, 30 ), Colour(0, 0, 0, 255), GUI_FLAG_TEXT_TAGS);
    chatbox.EditBox.FontSize = floor( 17 * GUI.GetScreenSize( ).Y / 1080 );
    chatbox.EditBox.TextColour = Colour(255, 255, 255, 255);
    chatbox.EditBox.FontName = "TR Tahoma Bold"
    chatbox.EditBox.FontFlags = GUI_FFLAG_OUTLINE;
    chatbox.EditBox.RemoveFlags( GUI_FLAG_BACKGROUND | GUI_FLAG_BORDER );
 chatbox.EditBox.Text = "";
 chatboxTimer <- Timer.Create(this, function(text, int) {
      chatbox.EditBox.Text = "";
   GUI.SetFocusedElement( chatbox.EditBox );
    }, 45, 1, "Timer Text ", 12345);
}
chatTimer <- null;
maxChatLine <- 15;
function chatProcess(readstr){
  if (chatbox.Box.LineHeight == 0){chatbox.Box.LineHeight = 1;}
    chatbox.Box.AddLine(readstr, Colour(255, 255, 255, 255))
    if(chatbox.Box.LineHeight < maxChatLine ){
      chatbox.Box.LineHeight += 1;
    }
    chatTimerProcess();
}

function chatTimerProcess(){
    Timer.Destroy( chatTimer );
    chatTimer <- Timer.Create(this, function(text, int) {
    if (chatbox.Box.LineHeight > 0 ){
      chatbox.Box.LineHeight -=1;
    }
    chatbox.Box.DisplayPos = 0;
 }, 10000, 0, "Timer Text ", 12345);
}
