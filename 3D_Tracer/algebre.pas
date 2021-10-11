unit algebre;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls;

type
  pfloat=^real;
  tfunc=function:real of object;
  texpr=class
  private
    fils:tlist;
    vars:pointer;
    vals:pfloat;
    text:string;
    cy,lx,ly:integer;
    function plus:real;
    function fois:real;
    function value:real;
    function variable:real;
    function ecos:real;
    function esin:real;
    function eln:real;
    function etan:real;
    function einverse:real;
    function eexp:real;
    function esqr:real;
    function esqrt:real;
    function eabs:real;
    function oppose:real;
  public
    valeur:tfunc;
    procedure normalize(c:tcanvas);
    procedure draw(c:tcanvas;x,y:integer);
    constructor create(s:string;const names:array of string;const addresses:array of pointer);
    destructor destroy;override;
  end;

implementation

function tan(x:real):real;
begin
  tan:=sin(x)/cos(x);
end;

constructor texpr.create(s:string;const names:array of string;const addresses:array of pointer);
label fini;
var
  t:tstringlist;
  a,b:integer;
  u:string;
begin
  inherited create;
  new(vals);
  fils:=tlist.create;
  t:=tstringlist.create;
  try
    if s='' then raise exception.create('Chaîne vide trouvée');
    b:=0;
    u:='';
    if s[1]='+' then s:=copy(s,2,length(s)-1);
    for a:=length(s) downto 1 do begin
      case s[a] of
        ')':inc(b);
        '(':dec(b);
        '+':if (b=0) and (a>1) then begin t.add(u);u:='';continue;end;
        '-':if (b=0) and (a>1) then begin t.add('-'+u);u:='';continue;end;
      end;
      u:=s[a]+u;
    end;
    if b>0 then raise exception.create('Il manque ''(''');
    if b<0 then raise exception.create('Il manque '')''');
    if t.count<>0 then begin
      t.add(u);
      u:='+';
      for a:=0 to t.count-1 do fils.add(texpr.create(t[a],names,addresses));
      valeur:=plus;
      goto fini;
    end;
    b:=0;
    u:='';
    for a:=length(s) downto 1 do begin
      case s[a] of
        ')':inc(b);
        '(':dec(b);
        '*':if b=0 then begin t.add(u);u:='';continue;end;
        '/':if b=0 then begin t.add('inverse('+u+')');u:='';continue;end;
      end;
      u:=s[a]+u;
    end;
    if t.count<>0 then begin
      t.add(u);
      u:='*';
      for a:=0 to t.count-1 do fils.add(texpr.create(t[a],names,addresses));
      valeur:=fois;
      goto fini;
    end;
    a:=1;
    u:='';
    while (a<=length(s)) and (s[a]<>'(') do begin
      u:=u+s[a];
      inc(a);
    end;
    @valeur:=nil;
    if u='abs' then valeur:=eabs;
    if u='cos' then valeur:=ecos;
    if u='sin' then valeur:=esin;
    if u='tan' then valeur:=etan;
    if u='ln' then valeur:=eln;
    if u='exp' then valeur:=eexp;
    if u='sqrt' then valeur:=esqrt;
    if u='sqr' then valeur:=esqr;
    if u='inverse' then valeur:=einverse;
    if s[1]='-' then begin valeur:=oppose;s:='-'+s+')';u:='-';end;
    if (@valeur<>nil) then begin
      fils.add(texpr.create(copy(s,length(u)+2,length(s)-length(u)-2),names,addresses));
      goto fini;
    end;
    if u='' then begin
      destroy;
      self:=texpr.create(copy(s,2,length(s)-2),names,addresses);
      u:=text;
      goto fini;
    end;
    u:=s;
    for b:=low(names) to high(names) do if s=names[b] then begin
      vars:=addresses[b];
      valeur:=variable;
      goto fini;
    end;
    vals^:=strtofloat(s);
    valeur:=value;
    fini:text:=u;
  finally
    t.free;
  end;
end;

function texpr.plus:real;
var
  a:integer;
  s:real;
begin
  s:=0;
  for a:=0 to fils.count-1 do s:=s+texpr(fils[a]).valeur;
  plus:=s;
end;

function texpr.fois:real;
var
  a:integer;
  s:real;
begin
  s:=1;
  for a:=0 to fils.count-1 do s:=s*texpr(fils[a]).valeur;
  fois:=s;
end;

function texpr.value:real;
begin
  value:=pfloat(vals)^;
end;

function texpr.variable:real;
begin
  variable:=pfloat(vars)^;
end;

function texpr.ecos:real;
begin
  ecos:=cos(texpr(fils[0]).valeur);
end;

function texpr.esin:real;
begin
  esin:=sin(texpr(fils[0]).valeur);
end;

function texpr.eln:real;
begin
  eln:=ln(texpr(fils[0]).valeur);
end;

function texpr.eexp:real;
begin
  eexp:=exp(texpr(fils[0]).valeur);
end;

function texpr.esqr:real;
begin
  esqr:=sqr(texpr(fils[0]).valeur);
end;

function texpr.esqrt:real;
begin
  esqrt:=sqrt(texpr(fils[0]).valeur);
end;

function texpr.etan:real;
begin
  etan:=tan(texpr(fils[0]).valeur);
end;

function texpr.eabs:real;
begin
  eabs:=abs(texpr(fils[0]).valeur);
end;

function texpr.einverse:real;
begin
  einverse:=1/texpr(fils[0]).valeur;
end;

function texpr.oppose:real;
begin
  oppose:=-texpr(fils[0]).valeur;
end;

destructor texpr.destroy;
var
  a:integer;
begin
  for a:=fils.count-1 downto 0 do texpr(fils[a]).destroy;
  dispose(vals);
  fils.destroy;
  inherited destroy;
end;

function min(x,y:integer):integer;
begin
  if x>y then min:=y else min:=x;
end;

function max(x,y:integer):integer;
begin
  if x<y then max:=y else max:=x;
end;

procedure texpr.normalize(c:tcanvas);
var
  a,b:integer;
begin
  {showmessage(text);}
  b:=c.textwidth(text[1])+2;
  lx:=-b+c.textwidth('()');
  case text[1] of
    '+':for a:=0 to fils.count-1 do begin
      texpr(fils[a]).normalize(c);
      lx:=lx+b+texpr(fils[a]).lx;
      ly:=max(ly-cy-3,texpr(fils[a]).ly)+3+max(cy,texpr(fils[a]).cy);
      cy:=max(cy,texpr(fils[a]).cy);
    end;
    '*':for a:=0 to fils.count-1 do begin
      texpr(fils[a]).normalize(c);
      if (a>0) and (texpr(fils[a]).text<>'inverse') then begin
        lx:=lx+b+texpr(fils[a]).lx;
        ly:=max(ly-cy-3,texpr(fils[a]).ly)+3+max(cy,texpr(fils[a]).cy);
        cy:=max(cy,texpr(fils[a]).cy);
      end else begin
        lx:=lx-texpr(fils[a-1]).lx+max(texpr(fils[a-1]).lx,texpr(fils[a]).lx);
        ly:=max(ly-cy-3,texpr(fils[a]).ly)+3+max(cy,texpr(fils[a-1]).ly);
        cy:=max(cy,texpr(fils[a-1]).ly);
      end;
    end;
  else
    if fils.count=0 then begin
      lx:=c.textwidth(text);
      ly:=c.textheight(text);
      cy:=ly div 2;
    end else begin
      texpr(fils[0]).normalize(c);
      lx:=c.textwidth(text)+texpr(fils[0]).lx+c.textwidth('(')+c.textwidth(')');
      cy:=texpr(fils[0]).cy;
      ly:=texpr(fils[0]).ly;
    end;
  end;
end;

procedure texpr.draw(c:tcanvas;x,y:integer);
var
  a,b:integer;
begin
  b:=c.textwidth(text[1])+2;
  case text[1] of
    '+','-':begin
      for a:=fils.count-1 downto 0 do begin
        texpr(fils[a]).draw(c,x,y+cy-texpr(fils[a]).cy);
        if texpr(fils[a]).text='-' then begin

        end else begin
          if a>0 then c.textout(x-b,y,'+');
        end;
        x:=x+texpr(fils[a]).lx+b;
      end;
    end;
    '*':begin
      for a:=fils.count-1 downto 0 do begin
        texpr(fils[a]).draw(c,x,y+cy-texpr(fils[a]).cy);
        x:=x+texpr(fils[a]).lx+b;
      end;
    end;
  else
    if fils.count=0 then begin
      c.TextOut(x,y,text);
    end else begin
      c.textout(x,y,text+'(');
      x:=x+c.textwidth(text+'(');
      texpr(fils[0]).draw(c,x,y+cy-texpr(fils[0]).cy);
      c.textout(x+texpr(fils[0]).lx,y,')');
    end;
  end;
end;

end.
