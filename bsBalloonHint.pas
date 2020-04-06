unit bsBalloonHint;
         //===================================================================================================//
        // © https://github.com/murrto/bsBalloonHint/ with ❤ by murr                                         //
       // Nice little Ballon Hint component with a close button and user defined position and display time: //
      //===================================================================================================//
     //  ¬   ¬                         ¬           ¬ ¬                   ¬    _        ¬  _               //
    // / / / /___ _____  ____   _   _/ /_   ___ _/ / /___   ___  ____  / /_  (_)___  / /_(_)___   ___ _  //
   // / /_/ /  _ `/ _  \/ _  \/ / / / _  \/  _ `/ / / __ \/ __ \/ _  \/ _  \/ / _  \/ __/ / _  \/  _ `/ //
  // / __  / (_/ / /_) / /_) / (_/ / /_) / (_/ / / / (_) / (_) / / ) / / ) / / / ) / (_/ / / ) / (_/ / //
 // /_/ /_/\__,_/ .___/ .___/\__, /_.___/\__,_/_/_/\____/\____/_/ /_/_/ /_/_/_/ /_/\__/_/_/ /_/\__, / //
//             /_/   /_/    <____/                                                            <____/ //
//                                                                                                  //
//=================================================================================================//                                                                                              //
//more info @ https://docs.microsoft.com/en-us/windows/win32/api/Commctrl/ns-commctrl-tttoolinfoa //
//==-USAGE:-=====================================================================================//
{uses
  bsBaloonHint;

procedure TForm1.Button1Click(Sender: TObject);
var lToolTipPoint: TPoint;
begin
  Button1.bsBalloonTip(TIconKind.Eror_Large,'Balloon Title','Balloon text', Button1.ClientToScreen(Point(0,0))); //appears from top left corner of the Button1
  lToolTipPoint := Form1.DBGrid.ClientToScreen(Point(Round(Form1.DBGrid.Width/2),Round(Form1.DBGrid.Height/2))); //getting DBGrid center to show a tip there
  bsBalloonTip(TIconKind.Info, 'Attention!', 'The values were updated!', lToolTipPoint, 2222); //showing tip for about 2 sec
end;}


interface
uses
  Controls, CommCtrl, Graphics, Windows;

{$SCOPEDENUMS ON}

type
  TIconKind = (None = TTI_NONE,
               Info = TTI_INFO,
               Warning = TTI_WARNING,
               Error = TTI_ERROR,
               Info_Large = TTI_INFO_LARGE,
               Warning_Large = TTI_WARNING_LARGE,
               Eror_Large = TTI_ERROR_LARGE);
  TComponentBalloonHint = class helper for TWinControl
  public
    procedure bsBalloonTip(Icon: TIconKind; const Title: string; const Text: string; DesiredPosition: TPoint; ShowingTime: System.Cardinal = 0);
    procedure CloseOnTimer(Sender: TObject);
  end;

implementation
uses
  Vcl.ExtCtrls; //needed for TTimer

var
  hWndToolTip: THandle;

{ TComponentBalloonHint }

procedure TComponentBalloonHint.bsBalloonTip(      Icon           : TIconKind;
                                             const Title          : string;
                                             const Text           : string;
                                                   DesiredPosition: TPoint;
                                                   ShowingTime    : System.Cardinal = 88888888); //leave blank to show until user closes it
var
  ToolInfo: TToolInfo;
  BodyText: pWideChar;
  ltimer: TTimer;
begin
  hWndToolTip :=  CreateWindow(TOOLTIPS_CLASS,
                          nil,
                          WS_POPUP or TTS_CLOSE or TTS_NOPREFIX or TTS_BALLOON or TTS_ALWAYSTIP,
                          CW_USEDEFAULT, CW_USEDEFAULT,
                          CW_USEDEFAULT, CW_USEDEFAULT,
                          Handle,
                          0,
                          HInstance,
                          nil);

if hWndToolTip = 0 then
    Exit;

  GetMem(BodyText, 2 * 256);

  try
    ToolInfo.cbSize := SizeOf(TToolInfo);
    ToolInfo.uFlags := TTF_TRACK or TTF_TRANSPARENT or TTF_SUBCLASS or TTF_ABSOLUTE;  //use TTF_CENTERTIP to position in the middle and below the parent window
    ToolInfo.hWnd := Handle;
    ToolInfo.lpszText := StringToWideChar(Text, BodyText, 2 * 356);

    SetWindowPos(hWndToolTip,
                 HWND_TOPMOST,
                 DesiredPosition.X,
                 DesiredPosition.Y,
                 0,
                 0,
                 SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
    ToolInfo.Rect := GetClientRect;

    if ShowingTime > 0 then
    begin
         ltimer := TTimer.Create(nil);
         ltimer.Enabled := false;
         ltimer.Interval := ShowingTime;
         ltimer.OnTimer := CloseOnTimer;
         ltimer.Enabled := true;
    end;

    SendMessage(hWndToolTip, TTM_TRACKACTIVATE, 0, Integer(@ToolInfo)); //deactivating previous tip
    SendMessage(hWndToolTip, TTM_SETTITLE, Integer(Icon), Integer(PChar(Title)));
    SendMessage(hWndToolTip, TTM_ADDTOOL, 1, Integer(@ToolInfo));
    SendMessage(hWndToolTip, TTM_TRACKPOSITION, 0, MakeLong(DesiredPosition.X, DesiredPosition.Y));
    SendMessage(hWndToolTip, TTM_TRACKACTIVATE, 1, Integer(@ToolInfo));
  finally
    FreeMem(BodyText);
    ltimer.FreeOnRelease;
  end;
end;

procedure TComponentBalloonHint.CloseOnTimer(Sender: TObject);
begin
     with Sender as TTimer do
     begin
          SendMessage(hWndToolTip, TTM_POP, 0, 0);
     end;
end;


end.
