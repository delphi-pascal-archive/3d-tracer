unit Face1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, algebre, ExtCtrls, ToolWin, Buttons, ExtDlgs;

type
  tmode=(msimple,mparametrique,mcylindrique,mspherique);
  tstyle=(fil,face,facette,lisse);
  tface=record
    a1,a2,a3,a4:integer;
    z:real;
  end;
  pface=^tface;
  tvect=record
    x,y,z:real;
  end;
  pvect=^tvect;
  tmat=array[1..3,1..3] of real;
  tfunction=function(x,y:real):tvect;
  TForm1=class(TForm)
    ScrollBox1: TScrollBox;
    PaintBox1: TPaintBox;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    StaticText1: TStaticText;
    ToolButton2: TToolButton;
    ProgressBar1: TProgressBar;
    ScrollBox2: TScrollBox;
    RadioGroup2: TRadioGroup;
    StaticText2: TStaticText;
    Edit1: TEdit;
    StaticText3: TStaticText;
    Edit2: TEdit;
    StaticText4: TStaticText;
    ComboBox1: TComboBox;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    CheckBox1: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    SavePictureDialog1: TSavePictureDialog;
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1Paint(Sender: TObject);
    procedure ToolBar1Resize(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure RadioGroup2Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    function getface(x:integer):tface;
    function getsommet(x:integer):tvect;
    procedure setsommet(x:integer;v:tvect);
    function getfacecount:integer;
    function getsommetcount:integer;
  public
    _faces,_sommets,_normals:tlist;
    o1,o2,o3:real;
    drag:bool;
    xx,yy:integer;
    procedure clear;
    procedure addfaces(f:tface);
    procedure addsommets(v,n:tvect);
    property faces[x:integer]:tface read getface;
    property sommets[x:integer]:tvect read getsommet write setsommet;
    property facecount:integer read getfacecount;
    property sommetcount:integer read getsommetcount;
    procedure normalize;
    procedure dessine(lx,ly:integer;c:tcanvas);
    procedure formule(f:tfunction;t1,t2:array of real;lx,ly:integer);
    procedure classe(a,b:integer);
    procedure apply;
    procedure peint;
  end;

var
  dz,rr:real;
  p:tbitmap;
  Form1: TForm1;
  u,v:real;
  umin,umax,vmin,vmax,expr1,expr2,expr3:texpr;
  style:tstyle;
  mode:tmode;
  mat:tmat;

const
  tau:real=1E-10;
  pii:real=pi;

const
  id:tmat=((1,0,0),(0,1,0),(0,0,1));

implementation

{$R *.DFM}

procedure tform1.peint;
begin
  if checkbox1.checked then
    paintbox1.canvas.stretchdraw(rect(0,0,paintbox1.width,paintbox1.height),p)
  else
    paintbox1.canvas.draw(0,0,p);
end;

function sphere(u,v:real):tvect;
begin
  sphere.x:=cos(u)*cos(v);
  sphere.y:=sin(u)*cos(v);
  sphere.z:=sin(v);
end;

function compose(a,b:tmat):tmat;
var
  i,j,k:integer;
  s:real;
begin
  for i:=1 to 3 do
    for j:=1 to 3 do begin
      s:=0;
      for k:=1 to 3 do s:=s+a[i,k]*b[k,j];
      compose[i,j]:=s;
    end;
end;

function image(m:tmat;v:tvect):tvect;
begin
  image.x:=m[1,1]*v.x+m[1,2]*v.y+m[1,3]*v.z;
  image.y:=m[2,1]*v.x+m[2,2]*v.y+m[2,3]*v.z;
  image.z:=m[3,1]*v.x+m[3,2]*v.y+m[3,3]*v.z;
end;

function rot(o1,o2,o3:real):tmat;
var
  m,n:tmat;
begin
  m:=id;
  m[2,2]:=cos(o1);
  m[3,3]:=cos(o1);
  m[3,2]:=sin(o1);
  m[2,3]:=-sin(o1);
  n:=id;
  n[1,1]:=cos(o2);
  n[3,3]:=cos(o2);
  n[3,1]:=-sin(o2);
  n[1,3]:=sin(o2);
  m:=compose(m,n);
  n:=id;
  n[1,1]:=cos(o3);
  n[2,2]:=cos(o3);
  n[2,1]:=sin(o3);
  n[1,2]:=-sin(o3);
  rot:=compose(m,n);
end;

function tform1.getface(x:integer):tface;
begin
  getface:=pface(_faces[x])^;
end;

function tform1.getsommet(x:integer):tvect;
begin
  getsommet:=pvect(_sommets[x])^;
end;

procedure tform1.setsommet(x:integer;v:tvect);
begin
  pvect(_sommets[x])^:=v;
end;

procedure tform1.addfaces(f:tface);
var
  p:pface;
begin
  new(p);
  p^:=f;
  _faces.add(p);
end;

procedure tform1.addsommets(v,n:tvect);
var
  p:pvect;
begin
  new(p);
  p^:=v;
  _sommets.add(p);
  new(p);
  p^:=n;
  _normals.add(p);
end;

procedure tform1.clear;
var
  a:integer;
begin
  for a:=facecount-1 downto 0 do dispose(pface(_faces[a]));
  _faces.clear;
  for a:=sommetcount-1 downto 0 do begin
    dispose(pvect(_sommets[a]));
    dispose(pvect(_normals[a]));
  end;
  _sommets.clear;
  _normals.clear;
end;

function tform1.getfacecount:integer;
begin
  getfacecount:=_faces.count;
end;

function tform1.getsommetcount:integer;
begin
  getsommetcount:=_sommets.count;
end;

procedure tform1.normalize;
var
  a:integer;
  h:real;
  m:tmat;
begin
  if abs(o1)+abs(o2)+abs(o3)>1E-5 then begin
    statictext1.caption:='Rotations';
    m:=rot(o1,o2,o3);
    mat:=compose(m,mat);
    o1:=0;
    o2:=0;
    o3:=0;
    h:=time;
    for a:=0 to sommetcount-1 do begin
      sommets[a]:=image(m,sommets[a]);
      pvect(_normals[a])^:=image(m,pvect(_normals[a])^);
      if time-h>tau then progressbar1.position:=trunc(100*a/(sommetcount-1));
    end;
  end;
  statictext1.caption:='Ordre';
  progressbar1.position:=100;
  if style<>fil then begin
    h:=time;
    for a:=0 to facecount-1 do begin
      with pface(_faces[a])^ do
        z:=sommets[a1].z+sommets[a2].z+sommets[a3].z+sommets[a4].z;
      if time-h>tau then progressbar1.position:=trunc(100*a/(sommetcount-1));
    end;
    progressbar1.position:=0;
    statictext1.caption:='Classement';
    classe(0,facecount-1);
  end;
end;

function couleur(t,u,v,w:tvect):tcolor;
var
  l:tvect;
  x:byte;
begin
  u.x:=(t.x+u.x+v.x+w.x)/4;
  u.y:=(t.y+u.y+v.y+w.y)/4;
  u.z:=(t.z+u.z+v.z+w.z)/4;
  l.x:=10;
  l.y:=10;
  l.z:=10;
  x:=trunc(
  255*abs(l.x*u.x+l.y*u.y+l.z*u.z)/
  sqrt((sqr(l.x)+sqr(l.y)+sqr(l.z)+1E-6)*(sqr(u.x)+sqr(u.y)+sqr(u.z)+1E-6)));
  couleur:=rgb(x,x,x);
end;

function couleur2(n:tvect):real;
begin
  couleur2:=abs(n.x+n.y+n.z)/sqrt(3);
end;

procedure lissage(p1,p2,p3,p4:tpoint;c1,c2,c3,c4:real;cdest:tcanvas);
var
  a,b,m,n:longint;
  c:byte;
begin
  m:=round(sqrt(2)*sqrt(sqr(p2.x-p1.x)+sqr(p2.y-p1.y)));
  n:=round(sqrt(2)*sqrt(sqr(p4.x-p1.x)+sqr(p4.y-p1.y)));
  if (n>0) and (m>0) then
    for a:=0 to m do
      for b:=0 to ((n*(m-a)) div m) do begin
        c:=trunc(255*(c1+(((c2-c1)*a)/m)+(((c4-c1)*b)/n)));
        cdest.pixels[round(p1.x+(p2.x-p1.x)*a/m+(p4.x-p1.x)*b/n),
                          round(p1.y+(p2.y-p1.y)*a/m+(p4.y-p1.y)*b/n)]:=rgb(c,c,c);
      end;
  m:=round(2*sqrt(sqr(p2.x-p3.x)+sqr(p2.y-p3.y)));
  n:=round(2*sqrt(sqr(p4.x-p3.x)+sqr(p4.y-p3.y)));
  if (n>0) and (m>0) then
    for a:=0 to m do
      for b:=0 to ((n*(m-a)) div m) do begin
        c:=trunc(255*(c3+(((c2-c3)*a)/m)+(((c4-c3)*b)/n)));
        cdest.pixels[round(p3.x+(p2.x-p3.x)*a/m+(p4.x-p3.x)*b/n),
                          round(p3.y+(p2.y-p3.y)*a/m+(p4.y-p3.y)*b/n)]:=rgb(c,c,c);
      end;
end;

procedure tform1.dessine(lx,ly:integer;c:tcanvas);
var
  a:integer;
  u1,u2,u3,u4:tvect;
  h:real;
  function poin(v:tvect):tpoint;
  begin
    poin.x:=trunc(lx*0.5*(1+rr*dz*v.x/(dz-v.z)));
    poin.y:=trunc(ly*0.5*(1-rr*dz*v.y/(dz-v.z)));
  end;
  procedure affiche;
  begin
    progressbar1.position:=trunc(100*a/(facecount-1));
    h:=time;
  end;
begin
  statictext1.caption:='Affichage';
  c.brush.color:=clwhite;
  c.Pen.color:=0;
  h:=time;
  case style of
    fil:for a:=0 to facecount-1 do with faces[a] do begin
      if time-h>tau then affiche;
      c.polyline([poin(sommets[a1]),poin(sommets[a2]),poin(sommets[a3]),poin(sommets[a4]),poin(sommets[a1])]);
    end;
    face:for a:=0 to facecount-1 do with faces[a] do begin
      if time-h>tau then affiche;
      c.polygon([poin(sommets[a1]),poin(sommets[a2]),poin(sommets[a3]),poin(sommets[a4])]);
    end;
    facette:for a:=0 to facecount-1 do with faces[a] do begin
      if time-h>tau then affiche;
      u1:=sommets[a1];
      u2:=sommets[a2];
      u3:=sommets[a3];
      u4:=sommets[a4];
      c.brush.color:=couleur(pvect(_normals[a1])^,pvect(_normals[a2])^,
                             pvect(_normals[a3])^,pvect(_normals[a4])^);
      c.pen.color:=c.brush.color;
      c.polygon([poin(u1),poin(u2),poin(u3),poin(u4)]);
    end;
    lisse:for a:=0 to facecount-1 do with faces[a] do begin
      if time-h>tau then affiche;
      lissage(poin(sommets[a1]),poin(sommets[a2]),poin(sommets[a3]),poin(sommets[a4]),
              couleur2(pvect(_normals[a1])^),couleur2(pvect(_normals[a2])^),
              couleur2(pvect(_normals[a3])^),couleur2(pvect(_normals[a4])^),
              c);
    end;
  end;
  progressbar1.position:=100;
end;

function fois(x:real;v:tvect):tvect;
begin
  fois.x:=x*v.x;
  fois.y:=x*v.y;
  fois.z:=x*v.z;
end;

function norm(v:tvect):real;
begin
  norm:=sqrt(sqr(v.x)+sqr(v.y)+sqr(v.z));
end;

function unitv(v:tvect):tvect;
begin
  unitv:=fois(1/(1E-6+norm(v)),v);
end;

function crossp(u,v:tvect):tvect;
begin
  crossp.x:=u.y*v.z-u.z*v.y;
  crossp.y:=v.x*u.z-u.x*v.z;
  crossp.z:=u.x*v.y-u.y*v.x;
end;

function moins(u,v:tvect):tvect;
begin
  moins.x:=u.x-v.x;
  moins.y:=u.y-v.y;
  moins.z:=u.z-v.z;
end;

procedure tform1.formule(f:tfunction;t1,t2:array of real;lx,ly:integer);
  function g(a,b:real):tvect;
  begin
    g:=f(a*t1[0]/lx+(1-a/lx)*t1[1],b*t2[0]/ly+(1-b/ly)*t2[1])
  end;
var
  a,b:integer;
  face:tface;
  h:real;
begin
  show;
  repaint;
  statictext1.caption:='Calcul des points';
  for a:=0 to lx do begin
    for b:=0 to ly do
      addsommets(g(a,b),unitv(crossp(fois(1/2E-5,moins(g(a+1E-5,b),g(a-1E-5,b))),
                 fois(1/2E-5,moins(g(a,b+1E-5),g(a,b-1E-5))))));
    progressbar1.position:=trunc(100*a/lx);
  end;
  statictext1.caption:='Calcul des faces';
  for a:=0 to lx-1 do begin
    for b:=0 to ly-1 do with face do begin
      a1:=(ly+1)*a+b;
      a2:=(ly+1)*a+b+1;
      a3:=(ly+1)*(a+1)+b+1;
      a4:=(ly+1)*(a+1)+b;
      addfaces(face);
    end;
    progressbar1.position:=trunc(100*a/lx);
  end;
  statictext1.caption:='Rotations';
  h:=time;
  for a:=0 to sommetcount-1 do begin
    sommets[a]:=image(mat,sommets[a]);
    pvect(_normals[a])^:=image(mat,pvect(_normals[a])^);
    if time-h>tau then progressbar1.position:=trunc(100*a/(sommetcount-1));
  end;
  apply;
  hide;
  showmodal;
end;

procedure tform1.classe(a,b:integer);
var
  c,d:integer;
begin
  if (b-a>1) then begin
    c:=(a+b) div 2;
    d:=a;
    repeat
      if faces[d].z>faces[c].z then begin
        _faces.exchange(d,c-1);
        _faces.exchange(c,c-1);
        dec(c);
      end else
        inc(d);
    until d=c;
    d:=b;
    repeat
      if faces[d].z<faces[c].z then begin
        _faces.exchange(d,c+1);
        _faces.exchange(c,c+1);
        inc(c);
      end else
        dec(d);
    until d=c;
    if c-1>a then classe(a,c-1);
    if c+1<b then classe(c+1,b);
  end else if faces[a].z>faces[b].z then _faces.exchange(a,b);
end;

procedure tform1.apply;
begin
  button1.enabled:=false;
  rr:=trackbar1.position/10;
  dz:=trackbar2.position;
  normalize;
  p.canvas.brush.color:=clwhite;
  p.canvas.rectangle(0,0,p.width,p.height);
  dessine(p.width,p.height,p.canvas);
  peint;
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  drag:=true;
  xx:=x;
  yy:=y;
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if drag then begin
    o2:=(x-xx)/100;
    o1:=(y-yy)/100;
    xx:=x;
    yy:=y;
    apply;
  end;
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  drag:=false;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  peint;
end;

procedure TForm1.ToolBar1Resize(Sender: TObject);
begin
  progressbar1.width:=toolbar1.width-toolbutton2.left-8;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
var
  s:string;
  a:byte;
begin
  s:=combobox1.items[combobox1.itemindex];
  a:=pos('*',s);
  p.width:=strtoint(copy(s,1,a-1));
  p.height:=strtoint(copy(s,a+1,length(s)-a));
  paintbox1.width:=p.width;
  paintbox1.height:=p.height;
  button1.enabled:=true;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  edit1.text:=floattostr(trackbar1.position/10);
  button1.enabled:=true;
end;

procedure TForm1.TrackBar2Change(Sender: TObject);
begin
  edit2.text:=inttostr(trackbar2.position);
  button1.enabled:=true;
end;

procedure TForm1.RadioGroup2Click(Sender: TObject);
begin
  style:=tstyle(radiogroup2.itemindex);
  button1.enabled:=true;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  if checkbox1.Checked then
    paintbox1.align:=alclient
  else begin
    paintbox1.align:=alnone;
    paintbox1.width:=p.width;
    paintbox1.height:=p.height;
  end;
  peint;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  combobox1.itemindex:=0;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  apply;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  trackbar1.position:=trackbar1.position-1;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
  trackbar1.position:=trackbar1.position+1;
end;

procedure TForm1.BitBtn3Click(Sender: TObject);
begin
  trackbar2.position:=trackbar2.position-1;
end;

procedure TForm1.BitBtn4Click(Sender: TObject);
begin
  trackbar2.position:=trackbar2.position+1;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if savepicturedialog1.execute
  then p.savetofile(savepicturedialog1.filename);
end;

initialization
  mat:=id;
end.
