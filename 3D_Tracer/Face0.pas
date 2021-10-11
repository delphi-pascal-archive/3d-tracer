unit Face0;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, face1, algebre, ExtCtrls;

type
  tformule=record
    t:array[1..8] of string;
    mode:tmode;
    style:tstyle;
    divu,divv,zoom,prof:word;
    m:tmat;
  end;
  pformule=^tformule;
  TForm0 = class(TForm)
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Button1: TButton;
    StaticText4: TStaticText;
    Edit4: TEdit;
    StaticText5: TStaticText;
    Edit5: TEdit;
    StaticText6: TStaticText;
    Edit6: TEdit;
    StaticText7: TStaticText;
    Edit7: TEdit;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    StaticText8: TStaticText;
    Edit8: TEdit;
    StaticText9: TStaticText;
    Edit9: TEdit;
    Button2: TButton;
    Button3: TButton;
    ListBox1: TListBox;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure RadioGroup2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  public
    procedure loadformule(f:tformule);
    procedure readconfig;
    procedure writeconfig;
  end;

var
  Form0: TForm0;

const
  tname:array[0..7] of string=('pi','u','v','x','y','z','teta','phi');
  taddresses:array[0..7] of pointer=(@pii,@u,@v,@u,@v,@v,@u,@v);

implementation

{$R *.DFM}

function f0(x,y:real):tvect;
begin
  u:=x;
  v:=y;
  f0.x:=x;
  f0.y:=y;
  f0.z:=expr1.valeur;
end;

function f1(x,y:real):tvect;
begin
  u:=x;
  v:=y;
  f1.x:=expr1.valeur;
  f1.y:=expr2.valeur;
  f1.z:=expr3.valeur;
end;

function f2(x,y:real):tvect;
var
  r:real;
begin
  u:=x;
  v:=y;
  r:=expr1.valeur;
  f2.x:=r*cos(x);
  f2.y:=r*sin(x);
  f2.z:=y;
end;

function f3(x,y:real):tvect;
var
  r:real;
begin
  u:=x;
  v:=y;
  r:=expr1.valeur;
  f3.x:=r*cos(x)*cos(y);
  f3.y:=r*sin(x)*cos(y);
  f3.z:=r*sin(y);
end;

procedure TForm0.Button1Click(Sender: TObject);
const
  tabfunc:array[msimple..mspherique] of tfunction=(f0,f1,f2,f3);
begin
  with form1 do begin
    _sommets:=tlist.create;
    _faces:=tlist.create;
    _normals:=tlist.create;
    drag:=false;
    expr1:=texpr.create(ansilowercase(form0.edit1.text),tname,taddresses);
    if mode=mparametrique then begin
      expr2:=texpr.create(ansilowercase(form0.edit2.text),tname,taddresses);
      expr3:=texpr.create(ansilowercase(form0.edit3.text),tname,taddresses);
    end;
    umin:=texpr.create(ansilowercase(edit4.text),tname,taddresses);
    umax:=texpr.create(ansilowercase(edit5.text),tname,taddresses);
    vmin:=texpr.create(ansilowercase(edit6.text),tname,taddresses);
    vmax:=texpr.create(ansilowercase(edit7.text),tname,taddresses);
    form1.formule(tabfunc[mode],[umin.valeur,umax.valeur],[vmin.valeur,vmax.valeur],
                  strtoint(edit8.text),strtoint(edit9.text));
    expr1.destroy;
    if mode=mparametrique then begin
      expr2.destroy;
      expr3.destroy;
    end;
    clear;
    _faces.destroy;
    _sommets.destroy;
    _normals.destroy;
  end;
end;

procedure TForm0.FormCreate(Sender: TObject);
begin
  dz:=10;
  rr:=1;
  p:=tbitmap.create;
  p.width:=512;
  p.height:=384;
  style:=tstyle(radiogroup2.itemindex);
  mode:=tmode(radiogroup1.itemindex);
  readconfig;
end;

procedure TForm0.RadioGroup1Click(Sender: TObject);
const
  tabstring1:array[msimple..mspherique,1..2] of string=
    (('x','y'),('u','v'),('teta','z'),('teta','phi'));
  tabstring2:array[msimple..mspherique,1..3] of string=
    (('Z','',''),('X','Y','Z'),('R','',''),('R','',''));
begin
  mode:=tmode(radiogroup1.itemindex);
  statictext2.visible:=mode=mparametrique;
  statictext3.visible:=statictext2.visible;
  edit2.visible:=statictext2.visible;
  edit3.visible:=statictext2.visible;
  statictext1.caption:=tabstring2[mode,1]+'('+tabstring1[mode,1]+','+tabstring1[mode,2]+')';
  statictext2.caption:=tabstring2[mode,2]+'('+tabstring1[mode,1]+','+tabstring1[mode,2]+')';
  statictext3.caption:=tabstring2[mode,3]+'('+tabstring1[mode,1]+','+tabstring1[mode,2]+')';
  statictext4.caption:=tabstring1[mode,1]+'min';
  statictext5.caption:=tabstring1[mode,1]+'max';
  statictext6.caption:=tabstring1[mode,2]+'min';
  statictext7.caption:=tabstring1[mode,2]+'max';
  statictext8.caption:='Divisions '+tabstring1[mode,1];
  statictext9.caption:='Divisions '+tabstring1[mode,2];
end;

procedure TForm0.RadioGroup2Click(Sender: TObject);
begin
  style:=tstyle(radiogroup2.itemindex);
end;

procedure TForm0.Button3Click(Sender: TObject);
label
  debut;
var
  s:string;
  f:tformule;
  p:pformule;
begin
  debut:s:='Nouvelle formule';
  if InputQuery('Nouvelle formule','Nom',s) then begin
    if listbox1.items.indexof(s)<>-1 then begin
      showmessage('Ce nom existe déjà, en donner un autre.');
      goto debut;
    end;
    f.t[1]:=s;
    f.t[2]:=edit1.text;
    if edit2.visible then f.t[3]:=edit2.text else f.t[3]:='';
    if edit3.visible then f.t[4]:=edit3.text else f.t[4]:='';
    f.t[5]:=edit4.text;
    f.t[6]:=edit5.text;
    f.t[7]:=edit6.text;
    f.t[8]:=edit7.text;
    f.divu:=strtoint(edit8.text);
    f.divv:=strtoint(edit9.text);
    f.style:=style;
    f.mode:=mode;
    f.zoom:=form1.trackbar1.position;
    f.prof:=form1.trackbar2.position;
    f.m:=mat;
    new(p);
    p^:=f;
    listbox1.items.addobject(s,tobject(p));
  end;
end;

procedure TForm0.ListBox1DblClick(Sender: TObject);
begin
  if listbox1.itemindex<>-1 then
    loadformule(pformule(listbox1.items.objects[listbox1.itemindex])^);
end;

procedure tform0.loadformule(f:tformule);
begin
  radiogroup1.itemindex:=ord(f.mode);
  radiogroup2.itemindex:=ord(f.style);
  edit1.text:=f.t[2];
  edit2.text:=f.t[3];
  edit3.text:=f.t[4];
  edit4.text:=f.t[5];
  edit5.text:=f.t[6];
  edit6.text:=f.t[7];
  edit7.text:=f.t[8];
  edit8.text:=inttostr(f.divu);
  edit9.text:=inttostr(f.divv);
  form1.trackbar1.position:=f.zoom;
  form1.trackbar2.position:=f.prof;
//  mat:=f.m;
end;

procedure TForm0.Button4Click(Sender: TObject);
begin
  with listbox1 do if itemindex<>-1 then 
    if MessageDlg('Supprimer '''+pformule(items.objects[itemindex])^.t[1]+''' ?',
      mtConfirmation,[mbYes,mbNo],0)=mryes then begin
      dispose(pformule(items.objects[itemindex]));
      items.delete(itemindex);
    end;
end;

procedure TForm0.Button2Click(Sender: TObject);
begin
  if listbox1.itemindex<>-1 then
    loadformule(pformule(listbox1.items.objects[listbox1.itemindex])^);
end;

procedure tform0.readconfig;
var
  a:integer;
  s:string[255];
  f:file;
  p:pformule;
  g:tformule;
  w:byte;
begin
  s:=extractfilepath(application.exename)+'courbes.dat';
  if fileexists(s) then begin
    assignfile(f,s);
    reset(f,1);
    try
      while not eof(f) do begin
        for a:=1 to 8 do begin
          blockread(f,w,1);
          blockread(f,s,w+1);
          g.t[a]:=s;
        end;
        blockread(f,g.mode,1);
        blockread(f,g.style,1);
        blockread(f,g.divu,2);
        blockread(f,g.divv,2);
        blockread(f,g.zoom,2);
        blockread(f,g.prof,2);
        blockread(f,g.m,54);
        new(p);
        p^:=g;
        listbox1.items.addobject(g.t[1],tobject(p));
      end;
    finally
      closefile(f);
    end;
  end else filecreate(s);
end;

procedure tform0.writeconfig;
var
  a,b:integer;
  s:string[255];
  f:file;
  g:tformule;
  w:byte;
begin
  s:=extractfilepath(application.exename)+'courbes.dat';
  assignfile(f,s);
  rewrite(f,1);
  try
    for b:=0 to listbox1.items.count-1 do begin
      g:=pformule(listbox1.items.objects[b])^;
      for a:=1 to 8 do begin
        w:=length(g.t[a]);
        blockwrite(f,w,1);
        s:=g.t[a];
        blockwrite(f,s,w+1);
      end;
      blockwrite(f,g.mode,1);
      blockwrite(f,g.style,1);
      blockwrite(f,g.divu,2);
      blockwrite(f,g.divv,2);
      blockwrite(f,g.zoom,2);
      blockwrite(f,g.prof,2);
      blockwrite(f,g.m,54);
      dispose(pformule(listbox1.items.objects[b]));
    end;
  finally
    closefile(f);
  end;
end;

procedure TForm0.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  writeconfig;
  p.destroy;
end;

end.
