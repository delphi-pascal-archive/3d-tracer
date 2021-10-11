program Faces;

uses
  Forms,
  Face1 in 'Face1.pas' {Form1},
  algebre in 'algebre.pas',
  Face0 in 'Face0.pas' {Form0};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm0, Form0);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
