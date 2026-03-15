{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}
unit ddansi2;

interface

uses
  dos, crt;

 {----------------------------------------------------------------------------}
 {                       Ansi screen emulation routines                       }
 {                              By Scott Baker                                }
{                        Revised By Derrick Parkhurst
{----------------------------------------------------------------------------}

 { Purpose: to execute ansi escape sequences locally. This includes changing  }
 {          color, moving the cursor, setting high/low intensity, setting     }
 {          blinking, and playing music.                                      }

 { Remarks: These routines use a few global variables which are defined       }
 {          below. So far, only ESC m, J, f, C, and ^N are supported by these }
 {          routines. I hope to include more in the future.                   }

 { Routines: Here is a listing of the subroutines:                            }

 {             change_color(x):      Change to ansi color code X.             }
 {             Eval_string(s):       Evaluate/execute ansi string             }
 {             ansi_write(ch):       Write a character with ansi checking     }

 {----------------------------------------------------------------------------}

var
  escape, blink, high, norm, any, any2, fflag, gflag: boolean;
  ansi_string: string;
const
  ddansibanner: boolean = True;

procedure ansi_write(ch: char);
procedure ansi_write_str(var s: string);
procedure initddansi;

implementation

const
  scale: array[0..7] of integer = (0, 4, 2, 6, 1, 5, 3, 7);
  scaleh: array[0..7] of integer = (8, 12, 10, 14, 9, 13, 11, 15);
var
  bbb:         boolean;
  restx, resty, curcolor: integer;

procedure change_color(c: integer);
begin;
  case c of
    00: begin;any := True;blink := False;high := False;norm := True;end;
    01: begin;high := True;end;
    02: begin;high := False;any := True;end; { dim/faint - remove bold }
    03: begin;end; { italic - no console support, ignore }
    04: begin;end; { underline - no console support, ignore }
    05: begin;blink := True;any := True;end;
    07: begin; { reverse video - swap foreground and background via TextAttr }
      any := True;
      any2 := True;
      fflag := True;
      gflag := True;
      { TextAttr low nibble = foreground, high nibble = background }
      textcolor((TextAttr shr 4) and $07);
      textbackground(TextAttr and $0F);
    end;
    08: begin;end; { concealed/hidden - no console support, ignore }
  end;
  if (c > 29) and (c < 38) then
  begin;
    any := True;
    any2 := True;
    c := c - 30;
    curcolor := c;
    if (high = True) and (blink = True) then
      textcolor(scaleh[c] + 32);
    if (high = True) and (blink = False) then
      textcolor(scaleh[c]);
    if (high = False) and (blink = True) then
      textcolor(scale[c] + 32);
    if (high = False) and (blink = False) then
      textcolor(scale[c]);
    fflag := True;
  end;
  if (c > 39) and (c < 48) then
  begin;
    any := True;
    c := c - 40;
    textbackground(scale[c]);
    gflag := True;
  end;
end;

{ Parse a decimal number from string s starting at position cp.
  Advances cp past all digit characters. Returns -1 if no digits found. }
function parse_ansi_num(var s: string; var cp: integer): integer;
var
  num: integer;
  found: boolean;
begin
  num := 0;
  found := False;
  while (cp <= length(s)) and (s[cp] >= '0') and (s[cp] <= '9') do
  begin
    num := num * 10 + (Ord(s[cp]) - Ord('0'));
    found := True;
    Inc(cp);
  end;
  if found then
    parse_ansi_num := num
  else
    parse_ansi_num := -1;
end;

procedure eval_string(var s: string);
var
  cp:    integer;
  T:     char;
  jj, a: integer;
begin;
  t := s[length(s)];
  cp := 2;
  case t of
    'k', 'K': clreol;
    'u': gotoxy(restx, resty);
    's': begin;
      restx := wherex;
      resty := wherey;
    end;
    'm', 'J': begin;
      while cp < length(s) do
      begin
        a := parse_ansi_num(s, cp);
        if a >= 0 then
          change_color(a);
        { skip non-digit separators (semicolons) }
        while (cp < length(s)) and ((s[cp] < '0') or (s[cp] > '9')) do
          Inc(cp);
      end;
      if norm then
      begin;
        if (fflag = False) and (gflag = False) then
        begin;textcolor(7);textbackground(0);curcolor := 7;end;
        if (fflag = False) and (gflag = True) then
        begin;textcolor(7);curcolor := 7;end;
        if (high = True) and (fflag = False) then
          textcolor(scaleh[curcolor]);
        if (blink = True) and (fflag = False) then
          textcolor(scale[curcolor] + 32);
        if (blink = True) and (high = True) and (fflag = False) then
          textcolor(scaleh[curcolor] + 32);
        if (fflag = True) and (gflag = False) then
        begin;textbackground(0);end;
      end;
      if any = False then
        textcolor(scaleh[curcolor]);
      { 5/12/95 srl }
      if (any2 = False) then
        if (high = True) then
        begin
          if (blink = True) then
            textcolor(scaleh[curcolor] + 32)
          else
            textcolor(scaleh[curcolor]);
        end else
        if (blink = True) then
          textcolor(scale[curcolor] + 32);

      any2 := False;any := False;fflag := False;gflag := False;norm := False;
    end;
    'C': begin;
      a := parse_ansi_num(s, cp);
      if a < 1 then a := 1;
      if wherex + a <= 80 then
        gotoxy(wherex + a, wherey);
    end;
    'D': begin;
      a := parse_ansi_num(s, cp);
      if a < 1 then a := 1;
      if wherex - a >= 1 then
        gotoxy(wherex - a, wherey);
    end;
    'A': begin;
      a := parse_ansi_num(s, cp);
      if a < 1 then a := 1;
      if wherey - a >= 1 then
        gotoxy(wherex, wherey - a);
    end;
    'B': begin;
      a := parse_ansi_num(s, cp);
      if a < 1 then a := 1;
      if wherey + a <= 25 then
        gotoxy(wherex, wherey + a);
    end;
    'f', 'H': begin;
      jj := parse_ansi_num(s, cp);
      if jj < 1 then jj := 1;
      { skip the semicolon separator }
      if (cp <= length(s)) and (s[cp] = ';') then
        Inc(cp);
      a := parse_ansi_num(s, cp);
      if a < 1 then a := 1;
      gotoxy(a, jj);
    end;
    else writeln(s);
  end;
end;

procedure ansi_write(ch: char);
begin;
  case ch of
    #12: clrscr;
    #09: repeat; Write(' '); until (wherex mod 8) = 1;
    #27: begin; escape := True; bbb := True; end;

    else begin;
      if escape then
      begin;
        if (bbb = True) and (ch <> '[') then
        begin;
          blink := False;
          high := False;
          escape := False;
          ansi_string := '';
          Write(#27);
        end else bbb := False;
        if escape then
        begin;
          ansi_string := ansi_string + ch;
          if ch = #13 then
            escape := False;
          if (ch in ['u', 's', 'A', 'B', 'C', 'D', 'H', 'm', 'J', 'f', 'K', 'k', #14]) then
          begin;
            escape := False;
            eval_string(ansi_string);
            ansi_string := '';
          end;
        end;
      end else Write(ch);
    end;
  end;
end;

procedure ansi_write_str(var s: string);
var
  a: integer;
  buf: string;

  procedure WriteBuf;
  begin
    if (buf <> '') then
    begin
      Write(buf);
      buf := '';
    end;
  end;

begin;
  buf := '';

  for a := 1 to length(s) do
  begin;
    case s[a] of
      #12: begin; WriteBuf(); clrscr; end;
      #09: begin; WriteBuf(); repeat; Write(' '); until (wherex mod 8) = 1; end;
      #27: begin; WriteBuf(); escape := True; bbb := True; end;

      else begin;
        if escape then
        begin;
          if (bbb = True) and (s[a] <> '[') then
          begin;
            WriteBuf();
            blink := False;
            high := False;
            escape := False;
            ansi_string := '';
            Write(#27);
          end else bbb := False;
          if escape then
          begin;
            ansi_string := ansi_string + s[a];
            if s[a] = #13 then
              escape := False;
            if (s[a] in ['u', 's', 'A', 'B', 'C', 'D', 'H', 'm', 'J', 'f', 'K', 'k', #14]) then
            begin;
              WriteBuf();
              escape := False;
              eval_string(ansi_string);
              ansi_string := '';
            end;
          end;
        end else buf := buf + s[a];
      end;
    end;
  end;
  WriteBuf();
end;

procedure InitDDAnsi;
begin;
  escape := False;
  ansi_string := '';
  blink := False;
  high := False;
end;

end.
