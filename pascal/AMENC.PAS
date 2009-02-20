Program Game1;
uses dos, crt;

Type
  Ptype_set = 'a'..'d';
level = record {has types of each of the below}
  description:string[100]; {the description of the square}
  items:array[1..4] of boolean; {change the size of this array to get more items in the square}
  mobs:array[1..4] of shortint;  {change the size of this array to get more mobs in the square}
  walk:boolean; {true or false variable}
end;

Charac = record
  Ptype, Pname:string[20];
  str, dex, hp, arm, int, maxmass, maxinv, expgot, expneed:integer;
  nitems, witems, levelc, chp, mana, cmana:integer;
end;

Var
  h, m, s, d, hund, diff,x , y:word;
  time, comptime:longint;
  currentlevel:array[1..9,1..9] of level;
  mobname, mobchar, items, skillx, name:string[20];
  SavedChar, Maincom:string[12];
  pre, SPT, Chartrue, nametrue, quitgame, trainagain, bora:char;
  f: text;
  z: file of charac;
  c: charac;
  count, tick:shortint;

Procedure Inventory;
begin
  Writeln(c.Pname,'`s Inventory');
  Writeln('------------------------------');
  Writeln('|Item name|   |Weight|   |No.|');
  Writeln('------------------------------');
  Writeln;
  Writeln;
  Writeln('------------------------------');
  Writeln('Max no. Items(',c.maxinv,') Max Weight(',c.maxmass,')');
end;

Procedure New_mob;
begin
end;



Procedure Statistics_char;
begin
end;

Procedure Skills;
begin
end;

Procedure Equipment;
begin
writeln;
writeln('-----------------------------------------');
writeln('|Item name|      |Quantity|      |Weight|');
writeln('-----------------------------------------');
writeln(Items,'              ',c.nitems,'         ',c.witems);
writeln('-----------------------------------------');
end;

Procedure Friend_mobs;
begin
Writeln('Your current friendly mobs are...');
writeln('-----------------------------------------');
writeln('|Mobs name|          |Character''s in mob|');
writeln('-----------------------------------------');
writeln(Mobname,'                 ',mobchar);
writeln('-----------------------------------------');
end;


Procedure main_commands;
begin
  gettime(h, m, s, hund);
  time:=(h*360);
  time:=time*10+(m*60)+(s);
  repeat

  textcolor(12);
  Write('<',c.chp,'hp|',c.hp,'hp * ',c.cmana,'m|',c.mana,'M * ',c.expgot,' C Exp|',c.expneed,' N Exp>   :   ');
  Readln(maincom);
  gettime(h, m, s, hund);
 comptime:=(h*360);
 comptime:=comptime*10+(m*60)+(s)+y;
 diff:=comptime-time;
 if diff >= 10 then
 begin
 x:=diff div 10;
 y:=diff mod 10;
 tick:=tick+x;
 writeln(tick);
 time:=comptime;
 end;
  for count := 1 to length(maincom) do
      maincom[count] := UPCASE(maincom[count]);

   If maincom = 'NEW MOB' then
 begin
 textcolor(14);
  New_mob;
 end;

   If (maincom = 'INVENTORY') or (maincom ='INVENTOR') or
    (maincom ='INVENTO') or (maincom ='INVENT') or
    (maincom ='INVEN') or (maincom ='INVE') or
    (maincom ='INV') or (maincom ='IN') then
 begin
 textcolor(14);
  Inventory;
 end

  else


   If (maincom = 'STATISTICS') or (maincom = 'STATISTIC') or
    (maincom = 'STATISTI') or (maincom = 'STATIST') or
    (maincom = 'STATIS') or (maincom = 'STATI') or
    (maincom = 'STAT') or (maincom = 'STA') or
    (maincom = 'ST') or (maincom = 'STATS') then
 begin
 textcolor(14);
  Statistics_char;
 end

  else


   If (maincom = 'EQUIPMENT') or (maincom = 'EQUIPMEN') or
    (maincom = 'EQUIPME') or (maincom = 'EQUIPM') or
    (maincom = 'EQUIP') or (maincom = 'EQUI') or
    (maincom = 'EQU') or (maincom = 'EQ') then
 begin
 textcolor(14);
  Equipment;
 end

  else

   If (maincom = 'SKILLS') or (maincom = 'SKILL') or
    (maincom = 'SKIL') or (maincom = 'SKI') or
    (maincom = 'SK') then
 begin
 textcolor(14);
  Skills;
 end

  else


   If (maincom = 'FRIENDS') or (maincom = 'FRIEND') or
    (maincom = 'FRIEN') or (maincom = 'FRIE') or
    (maincom = 'FRI') or (maincom = 'FR') then
 begin
 textcolor(14);
    Friend_mobs;
 end;

until (maincom = 'QUIT') or (maincom = 'QUI') or
    (maincom = 'QU') or (maincom = 'Q');

if (maincom = 'QUIT') or (maincom = 'QUI') or
    (maincom = 'QU') or (maincom = 'Q') then
begin
textcolor(11+128);
write('Do You Really Want To Quit (Y/N) : ');
readln(quitgame);
quitgame := UPCASE(quitgame);
end;
if quitgame = 'Y' then halt(0)

                  else main_commands;

end;


Procedure message_window;

begin
     Textbackground(black);
     Textcolor(white);
     Window(3,3,78,24);
     clrscr;
end;

Procedure menu_window;

begin
     textbackground(blue);
     textcolor(11+128);
     window(0,3,79,24);
     clrscr;
     writeln;
     writeln('       Created by AchromiciA & Crizmal                    AMENC v1.1 Alpha');

end;


Procedure Advanced_training;
begin
clrscr;
textcolor(10);
writeln('                   You have now entered Advanced training!');
readln;
end;

Procedure Basic_training;
begin
menu_window;
writeln('TRAINING                          TRAINING                          TRAINING');
message_window;
writeln('                   You have now entered Basic training!');
Writeln;
writeln('                          Press enter to continue.');
readln;
clrscr;
writeln('             First we will tell you about your HUD or display.');
readln;
writeln('In this Beta version you will not be able to configure your display but this');
writeln('                    will be acceptable in the full version.');
readln;
clrscr;
writeln;
writeln('   First in this beta version the command line will be all you will see.');
readln;
writeln('          Your command line is displayed in from left to right-');
readln;
writeln;
writeln('                           :Current Health [hp]');
writeln('                           :Maximum Health [hp]');
writeln('                           :Current mana [m]');
writeln('                           :Maximum mana [M]');
writeln('                           :Current Experience [C Exp]');
writeln('                           :Needed Experience [N Exp');
readln;
writeln;
writeln('                    An example of your HUD would be as shown.');
Writeln('                  <',c.chp,'hp|',c.hp,'hp * ',c.cmana,'m|',c.mana,'M * ',c.expgot,' C Exp|',c.expneed,' N Exp>');
readln;
clrscr;
writeln;
Writeln('    Now we will tell teach you how to get the computer to react to your');
writeln('                                    commands.');
writeln;
writeln;
readln;
writeln('     You will need to give the computer direct commands, which shall be');
writeln('                           typed underneath the HUD.');
writeln;
writeln;
readln;
clrscr;
writeln;
writeln;
writeln('  Some examples of these commands are... Inventory, Equipment, Skills, and');
writeln('          more that you will learn later in the training area.');
readln;
writeln;
writeln('But some of these commands can be shortended in smaller words... Inventory');
writeln('  (Inv), Equipment(eq), Skills(Sk), and again we will teach you later in');
writeln('                          this training area.');
readln;
repeat
gotoxy(5,13);
write('Would you like to continue to Advanced Training or Play Amenc : ');
readln(bora);
Bora := UPCASE(bora);
until bora in['P','A'];
If bora = 'A' then
begin
advanced_training;
end;
if bora = 'P' then
begin
clrscr;
gotoxy(0,14);
main_commands;
end;


end;

Procedure Training;
begin
 repeat
 clrscr;
textcolor(14);
Write('Would you like to do training before playing (Y/N) : ');
Readln(trainagain);
Until trainagain in ['Y','N','y','n'];
trainagain:=UPCASE(trainagain);
If trainagain = 'N' then
begin
   Main_commands;
end;

Clrscr;
writeln('Welcome to Training for AMENC v1.0 Beta this program will give you the low');
writeln('                      down for the structure of this game.');
writeln;
Writeln('                           Press Enter to Continue.');
Readln;

clrscr;

Write('What do you want to do... [Basic Training/Advanced Training/Play] : ');
readln(bora);
bora:=UPCASE(bora);

if bora = 'B' then
begin
  Basic_training;
end;

if bora = 'A'then
begin
  Advanced_Training;
end;

if bora = 'P' then
begin
main_commands;
end;

end;

Procedure statistics;
begin
mobname:='This function is not avaliable on the Alpha Version.';
mobchar:='0';
   If c.Ptype = 'Amazon' then
 begin
  c.str := 12;
  c.dex := 30;
  c.arm := 3;
  c.int := 15;
  c.chp := 200;
  c.hp := 200;
  c.cmana := 25;
  c.mana := 25;
  c.levelc := 1;
  c.expgot := 0;
  c.expneed := 250;
  c.maxmass := 240;
  c.maxinv := 80;
 end

    else

   If c.Ptype = 'Warrior' then
 begin
  c.str := 25;
  c.dex := 10;
  c.arm := 8;
  c.int := 5;
  c.chp := 130;
  c.hp := 130;
  c.cmana := 12;
  c.mana := 12;
  c.levelc := 1;
  c.expgot := 0;
  c.expneed := 250;
  c.maxmass := 325;
  c.maxinv := 40;
 end

    else

   If c.Ptype = 'Elf' then
 begin
  c.str := 8;
  c.dex := 20;
  c.arm := 10;
  c.int := 30;
  c.chp := 300;
  c.hp := 300;
  c.cmana := 40;
  c.mana := 40;
  c.levelc := 1;
  c.expgot := 0;
  c.expneed := 150;
  c.maxmass := 240;
  c.maxinv := 24;
 end

    else

   If c.Ptype = 'Peasent' then
 begin
  c.str := 15;
  c.dex := 18;
  c.arm := 5;
  c.int := 20;
  c.chp := 240;
  c.hp := 240;
  c.cmana := 30;
  c.mana := 30;
  c.levelc := 1;
  c.expgot := 0;
  c.expneed := 200;
  c.maxmass := 360;
  c.maxinv := 72;
 end;

assign(z, 'c:\tp\turbo\Amenc\'+c.pname+'.ame');
rewrite(z);
write(z, c);
close(z);

writeln;
Writeln('strength = ', c.str);
Delay(800);
Writeln('dexterity = ', c.dex);
Delay(400);
Writeln('armour = ', c.arm);
Delay(120);
writeln('intelligence = ', c.int);
Delay(4000);
writeln('Current Health = ',c.chp);
Delay(300);
Writeln('Health = ', c.hp);
Delay(100);
writeln('Current mana = ',c.cmana);
Delay(100);
writeln('Maximum mana = ',c.mana);
Delay(2500);
writeln('Current experience = ',c.expgot);
Delay(4800);
writeln('Needed experience = ',c.expneed);
Delay(1000);
writeln('Maximum Inventory weight = ',c.maxmass);
Delay(200);
writeln('Maximum Inventory size = ',c.maxinv);
Delay(200);
Writeln('Player Level = ', c.levelc);
Delay(800);
Writeln('Player type = ', c.Ptype);
Readln;

Training;

end;

Procedure CharName;
begin
 repeat
  Clrscr;
  Write('What do you want to call your character for this game : ');
  Readln(c.Pname);

  repeat
  Clrscr;
  Writeln('            ',c.Pname,' will be your name for the rest of the game,');
  write('                   are you sure you want to keep it   :   ');
  Readln(nametrue);
  Until nametrue in ['Y','N','y','n'];
  nametrue:=UPCASE(nametrue);
 Until nametrue = 'Y';
end;

Procedure Character_set;
begin
 Clrscr;
 Writeln('                       Allocating player stats...');


   If SPT = 'a' then
  begin
    c.Ptype := 'Amazon'
  end

    else

   If SPT = 'b' then
  begin
    c.Ptype := 'Warrior'
  end

    else

   If SPT = 'c' then
  begin
    c.Ptype := 'Elf'
  end

    else

   If SPT = 'd' then
  begin
    c.Ptype := 'Peasent'
  end;


end;

Procedure Character;
begin
textcolor(13);
  repeat
  Clrscr;
  Writeln('      What type of character do you what to use for your adventure...');
  Writeln;
  Writeln('                    Type the letter of your choice');
  Writeln;
  Writeln('                            <a> Amazon');
  Writeln('                            <b> Warrior');
  Writeln('                            <c> Elf');
  Writeln('                            <d> Peasent');
  Writeln;
  write('                   Please type letter in lower case : ');
  Readln(SPT);
  Until SPT in ['a','b','c','d'];

  repeat
  Clrscr;
  Write('   Are you sure that you want to choose this character (Y/N) : ');
  Readln(Chartrue);
  Until Chartrue in ['Y','N','y','n'];
  Chartrue:=UPCASE(Chartrue);
  If Chartrue = 'N' then
  begin
  character;
  end;

end;

procedure start;
  begin
  Writeln('Welcome to');
  textcolor(13);
  delay(1000);
  writeln('                  /\');
  Writeln('                 /  \                                   ||=======');
  Writeln('                /    \      |-      -|                  ||');
  Writeln('               /  /\  \     | \    / |                  ||');
  Writeln('              /  /  \  \    |  \  /  | ||===== ||====\  ||');
  Writeln('             /   ----   \   ||\ \/ /|| ||      ||====\\ ||');
  Writeln('            /            \  || \--/ || ||===   ||    || ||');
  Writeln('           /   /------\   \ ||      || ||      ||    || ||');
  Writeln('          /   /        \   \||      || ||===== ||    || ||=======');


Writeln;
Writeln;
textcolor(white);
Writeln('                         Press enter to continue.');
Readln;


repeat
clrscr;

textcolor(12);
Write('           Have you got a character previously created (Y/N) : ');
Readln(Pre);
Until Pre in ['y','Y','n','N'];
Pre:=UPCASE(pre);
 If Pre = 'Y' then
 begin
 writeln;
 write('           What is your existing character''s name : ');
 readln(name);

 assign(z, 'c:\tp\turbo\Amenc\'+name+'.ame');
 reset(z);
 read(z, c);
 close(z);

 
 clrscr;
 textcolor(10);
 writeln('                             Loading...');
 writeln;
 writeln('                      Players name |',c.Pname,'|');
 writeln('                       Player type |',c.Ptype,'|');
 writeln('                          strength |',c.str,'|');
 writeln('                         dexterity |',c.dex,'|');
 writeln('                            armour |',c.arm,'|');
 writeln('                      intelligence |',c.int,'|');
 writeln('                    Current Health |',c.chp,'|');
 writeln('                            Health |',c.hp,'|');
 writeln('                     Current level |',c.levelc,'|');
 writeln('                Current Experience |',c.expgot,'|');
 Writeln('                 Needed Experience |',c.expneed,'|');
 writeln('          Maximum Inventory weight |',c.maxmass,'|');
 writeln('            Maximum Inventory size |',c.maxinv,'|');
 writeln('                      Current mana |',c.cmana,'|');
 writeln('                      Maximum mana |',c.mana,'|');
 readln;
 main_commands;
end;
end;

begin
clrscr;
menu_window;
message_window;
start;
character;
charname;
character_set;
statistics;
training;


end.