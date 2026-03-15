{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}
{

Copyright 2007 Jakob Dangarden

 This file is part of Usurper.

    Usurper is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    Usurper is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Usurper; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
}

program Editor;

 {Usurper - DoorGame Editor}
 {Tools:Borland Pascal 7.0 and TurboVision 2.0}

                {to change version and year: look for uver in version.pas}

                {looking for the reset game proc? look in init.pas
                 Procedure ResDialog.HandleEvent(var Event:TEvent);}




uses
 {$IFDEF MSDOS}Overlay, {$ENDIF} Init, CfgVal, JakobE, muffi2, extra, file_io,
 levres, guardres, addit, edweap01, edbody, edrings, edneck, edshield,
 edhead, edface, eddrink, edarms, edhands, edwaist, edfeets, edabody,
 edlegs, edfood, edmonst, mon_arm, edarmor, eweapon, npc, resettn, moatres,
 Version
 {$IFDEF FPC}, RPPort, BaseUnix{$ENDIF};

{$IFDEF MSDOS}
  {---$O Addit}
  {---$O CfgHelp}
  {---$O helpfile}
  {$O CfgVal}
  {$O CfgDef}
  {$O Extra}
  {$O Edweap01}
  {$O Edweap}
  {$O Edweap2}
  {$O Edweap3}
  {$O Edmonst}
  {$O edface}          {*biker game*}
  {$O eddrink}         {*grave.diggers* *vultures* *slaves* *black hawks*}
  {$O edrings}         {undertaker,}
  {$O edshield}        {zonk,septic,death,buzzard,69,ferret,stinky,}
  {$O edbody} {bad max,scrag,hooks,toad,pinball,stone,midnight,}
  {$O edhead}{vanessa,stinkfinger,ferret}
  {$O edneck}
  {$O edarms}
  {$O edhands}
  {$O edwaist}
  {$O edfeets}
  {$O edabody}
  {$O edlegs}
  {$O edfood}
  {$O guardres}
  {$O levres}
  {$O mon_arm}
  {$O Npc}
  {$O resettn}
{$ENDIF}

var
  i:    longint;

  s: string;

  txt:  Text;
  dbg:  Text;

begin
  {DEBUG: Very first thing - write to file}
  Assign(dbg, 'DEBUG_TRACE.LOG');
  Rewrite(dbg);
  WriteLn(dbg, 'Program started');
  Str(ParamCount, s);
  WriteLn(dbg, 'ParamCount=' + s);
  for i := 1 to ParamCount do
  begin
    WriteLn(dbg, 'Param[' + ParamStr(i) + ']');
  end;
  Flush(dbg);
  
  filemode := 66;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
{$IFDEF MSDOS}
  {Overlay}
  OvrFilemode := 64;
  OvrInit('EDITOR.OVR');
  OvrInitEMS;
{$ENDIF}

  WriteLn(dbg, 'TRACE: after filemode');
  Flush(dbg);

  {Assign some files}
  Assign(monsterfile, monfile);
  Assign(guardfile, gufile);
  Assign(levelfile, lvlfile);

  WriteLn(dbg, 'TRACE: after assign files');
  Flush(dbg);

  {Checking if DATA, SCORES and NODE directories exist}
  if direxist(global_datadir) = False then
  begin
    WriteLn(dbg, 'TRACE: creating DATA dir');
    Flush(dbg);
    wrl('Directory "' + global_datadir + '" doesn''t exist!');
    wrl('Creating...');
    s := copy(global_datadir, 1, length(global_datadir) - 1);
    if make_dir(s) = False then
    begin
      unable_to_createdir(global_datadir);
      halt;
    end;
  end;

  WriteLn(dbg, 'TRACE: after datadir check');
  Flush(dbg);

  if direxist(global_nodedir) = False then
  begin
    WriteLn(dbg, 'TRACE: creating NODE dir');
    Flush(dbg);
    wrl('Directory "' + global_nodedir + '" doesn''t exist!');
    wrl('Creating...');
    s := copy(global_nodedir, 1, length(global_nodedir) - 1);
    if make_dir(s) = False then
    begin
      unable_to_createdir(global_nodedir);
      halt;
    end;
  end;

  WriteLn(dbg, 'TRACE: after nodedir check');
  Flush(dbg);

  if direxist(global_scoredir) = False then
  begin
    WriteLn(dbg, 'TRACE: creating SCORES dir');
    Flush(dbg);
    wrl('Directory "' + global_scoredir + '" doesn''t exist!');
    wrl('Creating...');
    s := copy(global_scoredir, 1, length(global_scoredir) - 1);
    if make_dir(s) = False then
    begin
      unable_to_createdir(global_scoredir);
      halt;
    end;
  end;

  WriteLn(dbg, 'TRACE: after scoredir check');
  Flush(dbg);

  {Check if the the datafiles should be created}
  Rewrite_DatFiles(False);

  WriteLn(dbg, 'TRACE: after Rewrite_DatFiles');
  Flush(dbg);

  add_fake := False;
  registered := 0;
  if f_exists(ucfg) = True then
  begin
    WriteLn(dbg, 'TRACE: calling terminate');
    Flush(dbg);
    terminate;
  end;

  WriteLn(dbg, 'TRACE: after terminate');
  Flush(dbg);

  {new editor stuff}
  cfgchang := False;
  if f_exists(ucfg) then
  begin
    WriteLn(dbg, 'TRACE: calling load_config');
    Flush(dbg);
    load_config;
  end else
  begin

    for i := 1 to maxallows do
    begin
      allowitem[i] := True;
    end;

    create_default_config(False);

  end;

  WriteLn(dbg, 'TRACE: after config');
  Flush(dbg);

  {creating ORIGINAL BACKUP, which saves changes before exit of program}
  for i := 1 to global_maxcdef do
  begin
    cfgurb[i] := cfgvalue[i];
  end;

  {bad solution here, should use streams I guess.}
  currp := 1;    {pointer to current user in NPC/PLAYER Editor}
  currg := 1;    {pointer to current doorguard in doorguard editor}
  currd := 1;    {pointer to current drink in drink editor}
  currm := 1;    {pointer to current monster in monster editor}
  curri := 1;    {pointer to current item in item editor}
  currmoat := 1; {pointer to current moat creature in the moat editor}
  currgod := 1; {pointer to current god in the god editor}
  currchild := 1; {pointer to current child in the children editor}

  depend := False;

  WriteLn(dbg, 'TRACE: before classic check');
  Flush(dbg);

  {Reading NEW or OLD Game mode}
  if open_txtfile(treset, txt, ucfg) then
  begin
    for i := 1 to 91 do
    begin
      readln_from_text(txt, s);
    end;
    close_text(txt);
  end else
  begin
    {unable to open Usurper.cfg}
    unable_To_access(ucfg);
  end;

  if upcasestr(s) = 'CLASSIC' then
    classic := True
  else classic := False;

  {the standard pascal randomize routine}
  Randomize;

  WriteLn(dbg, 'TRACE: before /RESET check');
  Flush(dbg);

  {Check for /RESET command line parameter - headless game reset}
  for i := 1 to ParamCount do
  begin
    WriteLn(dbg, 'TRACE: checking param [' + ParamStr(i) + ']');
    Flush(dbg);
    if UpCaseStr(ParamStr(i)) = '/RESET' then
    begin
      WriteLn(dbg, 'TRACE: /RESET MATCHED!');
      Flush(dbg);
      wrl('Usurper Editor ' + uver + ' - Headless Reset');
      wrl('');

      {Delete game state files (same as ResDialog.HandleEvent with game=true)}
      wrl('Clearing game state files...');
      if f_exists(innfile1) then delete_file(innfile1);
      if f_exists(innfile2) then delete_file(innfile2);
      if f_exists(nwfileans) then delete_file(nwfileans);
      if f_exists(nwfileasc) then delete_file(nwfileasc);
      if f_exists(ynwfileasc) then delete_file(ynwfileasc);
      if f_exists(datefile) then delete_file(datefile);
      if f_exists(mafile) then delete_file(mafile);
      if f_exists(marketfile) then delete_file(marketfile);
      if f_exists(chestfile) then delete_file(chestfile);
      if f_exists(armofile) then delete_file(armofile);
      if f_exists(weapofile) then delete_file(weapofile);
      if f_exists(wwfile) then delete_file(wwfile);
      if f_exists(truthfile1) then delete_file(truthfile1);
      if f_exists(truthfile2) then delete_file(truthfile2);
      if f_exists(teamrecordf) then delete_file(teamrecordf);
      if f_exists(teamrecfile) then delete_file(teamrecfile);
      if f_exists(indianfile) then delete_file(indianfile);
      if f_exists(kingfile) then delete_file(kingfile);
      if f_exists(rquestf) then delete_file(rquestf);
      if f_exists(relationf) then delete_file(relationf);
      if f_exists(childrenf) then delete_file(childrenf);
      if f_exists(barrelf) then delete_file(barrelf);
      if f_exists(drinkfile) then delete_file(drinkfile);

      {Score/history files}
      if f_exists(MonarchsANSI) then delete_file(MonarchsANSI);
      if f_exists(MonarchsASCI) then delete_file(MonarchsASCI);
      if f_exists(MarrHistANSI) then delete_file(MarrHistANSI);
      if f_exists(MarrHistASCI) then delete_file(MarrHistASCI);
      if f_exists(ChildBirthHistANSI) then delete_file(ChildBirthHistANSI);
      if f_exists(ChildBirthHistASCI) then delete_file(ChildBirthHistASCI);
      if f_exists(Global_VersionF) then delete_file(Global_VersionF);

      {Reset level limits}
      wrl('Creating Level Limits...');
      Reset_Levels;

      {Reset door guards}
      wrl('Creating Door Guards...');
      Reset_DoorGuards;

      {Reset items and equipment}
      wrl('Creating Items...');
      Rewrite_Datfiles(True);
      Count_Objects;
      Reset_Monster_Weapons;
      Reset_body;
      Reset_rings;
      Reset_neck;
      Reset_shields;
      Reset_head;
      Reset_face;
      Reset_drink;
      Reset_arms;
      Reset_hands;
      Reset_waist;
      Reset_feets;
      Reset_abody;
      Reset_legs;
      Reset_food;

      {Reset monsters}
      wrl('Creating Monsters...');
      Count_Monsters;
      Reset_Monsters;
      wrl('Arming Monsters...');
      Arm_Monsters;

      {Reset classic armors and weapons}
      wrl('Creating Armors (CLASSIC)...');
      count_oldarmors;
      Reset_Armor;
      wrl('Creating Weapons (CLASSIC)...');
      count_oldweapons;
      Reset_Weapon;

      {Reset NPCs (must be last - reads from other files)}
      wrl('Creating Computer Characters...');
      if f_exists(global_npfile) then delete_file(global_npfile);
      count_npcs;
      reset_npcs;

      {Reset teams and moat}
      reset_teamnames;
      reset_moatcreatures;

      {Delete player data}
      if f_exists(global_pfile) then delete_file(global_pfile);
      if f_exists(childrenf) then delete_file(childrenf);

      {Write version file}
      if Open_TxtFile(TReWrite, txt, Global_VersionF) then
      begin
        WriteLn_To_Text(txt, uver);
        Close_Text(txt);
      end else
      begin
        Unable_To_Create(Global_VersionF);
      end;

      wrl('');
      wrl('Usurper has been RESET!');
      WriteLn(dbg, 'TRACE: RESET COMPLETE');
      Close(dbg);
      {Use fpExit to bypass TurboVision finalization handlers that hang}
      {$IFDEF FPC}
      fpExit(0);
      {$ELSE}
      halt(0);
      {$ENDIF}
    end;
  end;
  WriteLn(dbg, 'TRACE: No /RESET found, starting UI');
  Close(dbg);

  {turbo vision is running!}
  vision_is_running := True;

  {Run the Editor Application}
  {$IFNDEF FPC}
  i := memavail;
  if i <> memavail then
  begin
    wrl('Out of Heap space! (give me some memory!)');
  end else
  begin
  {$ENDIF}
    MyApp.init;
    MyApp.run;
    MyApp.done;
  {$IFNDEF FPC}
  end;
  {$ENDIF}

end. {End Of Program}
