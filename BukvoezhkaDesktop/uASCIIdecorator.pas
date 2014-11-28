unit uASCIIdecorator;

// ����� ��������� �������������� �������� � ����� - fabiin
// (2003, http://codes-sources.commentcamarche.net/source/12384-ascii-t-petit-soft-d-ascii-art)

interface

uses Windows, SysUtils, Graphics, Classes;

type
  TDen = record // ��� ������� �� ��������� ����
    Car: Char; // ������
    D: integer; // ���
  end;

type
  TASCIIdecorator = class(TComponent)
  private
  var
    Densite: array [0 .. 95] of TDen; // ������ �������� �� ���������� �� �������
    procedure QuickSort(iLo, iHi: integer);
  public
    // contrast 247-255
    function MakeASCIIfromBitmap(SrcBitmap: TBitmap; DonorFont: string = 'Lucida Console';
      contrast: integer = 255; zoom: integer = 0; negative: boolean = false;
      CharacterSet: Byte = 0): string;
    function MakeASCIIfromText(SrcText: string; DonorFont: string = 'Lucida Console';
      contrast: integer = 255; zoom: integer = 0; negative: boolean = false; CharacterSet: Byte = 0;
      RenderFontSize: integer = 100): string;
  end;

implementation

procedure TASCIIdecorator.QuickSort(iLo, iHi: integer);
var
  Lo, Hi: integer;
  Mid: single;
  T: TDen;
begin
  Lo := iLo;
  Hi := iHi;
  if (Hi + Lo) <= 0 then
    exit;
  Mid := Densite[(Hi + Lo) div 2].D;
  repeat
    while Densite[Lo].D < Mid do
      Inc(Lo);
    while Densite[Hi].D > Mid do
      Dec(Hi);
    if Lo <= Hi then
    begin
      // VisualSwap(A[Lo], A[Hi], Lo, Hi);
      T := Densite[Lo];
      Densite[Lo] := Densite[Hi];
      Densite[Hi] := T;
      Inc(Lo);
      Dec(Hi);
    end;
  until Lo > Hi;
  if Hi > iLo then
    QuickSort(iLo, Hi);
  if Lo < iHi then
    QuickSort(Lo, iHi);
  // if Terminated then Exit;
end;

function TASCIIdecorator.MakeASCIIfromBitmap(SrcBitmap: TBitmap;
  DonorFont: string = 'Lucida Console'; contrast: integer = 255; zoom: integer = 0;
  negative: boolean = false; CharacterSet: Byte = 0): string;

  procedure FaireTblDensite; // ������� ������� ���������
  var
    a, b, c: integer;
    TmpB: TBitmap;
    chaLow, chaHi: integer;
    charactersArr: array of Char;
    startChar: integer;
  begin
    TmpB := TBitmap.Create; // ������� ��������� �����
    TmpB.Height := 50;
    TmpB.Width := 50;
    TmpB.Canvas.Brush.Color := clwhite;
    TmpB.Canvas.Pen.Color := clwhite;
    TmpB.Canvas.Font.Color := clblack;
    TmpB.Canvas.Font.Name := DonorFont;
    // �������������
    chaLow := 0;
    chaHi := chaLow + Length(Densite) - 1;
    // ��������� ����� ��������, �������� ����� ��������
    case CharacterSet of
      1:
      // ������� ����������/Block Elements 2580�259F
        begin
          charactersArr := ['W', '@', '#', '*', '+', ':', '.', ',', ' '];
          startChar := 9600;
        end;
      2:
      // ��������� 0400�04FF
        begin
          charactersArr := ['W', '@', '#', '*', '+', ':', '.', ',', ' '];
          startChar := 1040;
        end;
      3:
      // ���������/��������������� ��������� ��� 4E00�9FCC V1
        begin
          charactersArr := ['W', '@', '#', '*', '+', ':', '.', ',', ' '];
          startChar := 20096;
        end;
      4:
      // ���������/��������������� ��������� ��� 4E00�9FCC V2
        begin
          charactersArr := ['W', '@', '#', '*', '+', ':', '.', ',', ' '];
          startChar := 19968;
        end;
      else
      // ���������� ASCII ��� 32-126
      begin
        charactersArr := [' '];
        startChar := 32;
      end;
    end;
    // ����������� charactersArr
    for c := startChar to startChar + (Length(Densite) - Length(charactersArr)) do
      charactersArr := charactersArr + [chr(c)];
    // ���������� ������ ��������
    for c := chaLow to chaHi do
    begin
      Densite[c - chaLow].Car := charactersArr[c]; // ���������� ������ � ������ "������"
      Densite[c - chaLow].D := 0;
      // ������ ������
      TmpB.Canvas.Rectangle(0, 0, TmpB.Width, TmpB.Height);
      TmpB.Canvas.TextOut(0, 0, charactersArr[c]);
      // ������ ������ (?)
      for a := 1 to 20 do
      begin
        for b := 1 to 20 do
        begin
          if TmpB.Canvas.Pixels[a, b] = clwhite then
            Densite[c - chaLow].D := Densite[c - chaLow].D + 1;
        end;
      end;
    end;
    //
    FreeAndNil(TmpB);
    QuickSort(low(Densite), high(Densite));
  end;

var
  a, b, c, D: integer;
  MoyR, MoyG, MoyB, MoyCol: integer; // ��� ������� �����
  Couleur: LongInt;
  TmpB: TBitmap; // ������� ������
  TmpRec: TRect;
  TmpStr: string;

begin
  Result := '';
  FaireTblDensite;
  // �������� �����������
  TmpB := TBitmap.Create;
  if zoom in [0, 1] then
  begin // ������� ������
    TmpB.Height := SrcBitmap.Height;
    TmpB.Width := SrcBitmap.Width;
    TmpB.pixelformat := pf24bit;
    TmpB.Canvas.Draw(0, 0, SrcBitmap);
  end
  else
  begin // ����������
    TmpRec.Left := 0;
    TmpRec.Top := 0;
    TmpRec.Right := SrcBitmap.Width * zoom;
    TmpRec.Bottom := SrcBitmap.Height * zoom;

    TmpB.Height := SrcBitmap.Height * zoom;
    TmpB.Width := SrcBitmap.Width * zoom;
    TmpB.pixelformat := pf24bit;
    TmpB.Canvas.StretchDraw(TmpRec, SrcBitmap);
  end;

  TmpStr := '';

  b := 0; // ������� ����������� 8 * 16 �����
  while b < TmpB.Height - 16 - 1 do
  begin
    a := 0;
    while a < TmpB.Width - 8 - 1 do
    begin
      MoyCol := 0;
      MoyR := 0;
      MoyG := 0;
      MoyB := 0;
      // ����� ������� ���� �������
      c := a;
      while (c <= a + 8) and (c < TmpB.Width) do
      begin // ������� ������� ����������� 8 * 16
        D := b;
        while (D <= b + 16) and (D < TmpB.Height) do
        begin
          Couleur := ColorToRGB(TmpB.Canvas.Pixels[c, D]);
          MoyR := MoyR + GetRValue(Couleur);
          MoyG := MoyG + GetGValue(Couleur);
          MoyB := MoyB + GetBValue(Couleur);
          Inc(D, 1);
        end;
        Inc(c, 1);
      end;

      MoyR := MoyR div 152;
      MoyG := MoyG div 152;
      MoyB := MoyB div 152;

      // ��������� ������������� / �������
      MoyR := round(MoyR * (1 + (128 - 128) / 100));
      MoyG := round(MoyG * (1 + (128 - 128) / 100));
      MoyB := round(MoyB * (1 + (128 - 128) / 100));

      MoyR := round(MoyR + (contrast - 128) / 100 * (MoyR - 127));
      MoyG := round(MoyG + (contrast - 128) / 100 * (MoyG - 127));
      MoyB := round(MoyB + (contrast - 128) / 100 * (MoyB - 127));

      MoyCol := (MoyR + MoyG + MoyB) div 3; // ������������� �����
      if MoyCol > 255 then
        MoyCol := 255;
      if MoyCol < 0 then
        MoyCol := 0;
      // ������� (������������� �����):
      if negative then
        MoyCol := 255 - MoyCol;

      // ��������� �������� ��������� (��������� 255 � 95)
      MoyCol := round(MoyCol * ((Length(Densite) - 1) / 255));

      TmpStr := TmpStr + Densite[MoyCol].Car; // �������� ��������� ������ (?)

      Inc(a, 8);
    end;
    TmpStr := TmpStr + sLineBreak; // ������� ������
    Inc(b, 16);
  end;
  // fin
  FreeAndNil(TmpB);
  Result := TmpStr;
end;

function TASCIIdecorator.MakeASCIIfromText(SrcText: string; DonorFont: string = 'Lucida Console';
  contrast: integer = 255; zoom: integer = 0; negative: boolean = false; CharacterSet: Byte = 0;
  RenderFontSize: integer = 100): string;
var
  TmpBitmap: TBitmap;
  wh: TSize;
begin
  Result := '';
  if SrcText.Length > 0 then
  begin
    TmpBitmap := TBitmap.Create;
    // ����� ��������� ������
    TmpBitmap.Canvas.Font.Style := [fsBold];
    TmpBitmap.Canvas.Font.Size := RenderFontSize;
    TmpBitmap.Canvas.Font.Name := DonorFont;
    TmpBitmap.Canvas.Brush.Style := bsSolid;
    // ����� ������ �������
    wh := TmpBitmap.Canvas.TextExtent(SrcText);
    TmpBitmap.Width := wh.Width;
    TmpBitmap.Height := wh.Height;
    TmpBitmap.Canvas.FloodFill(0, 0, clwhite, fsSurface); // �������� �����
    // ������� �
    TmpBitmap.Canvas.TextRect(TmpBitmap.Canvas.ClipRect, 0, 0, SrcText);
    // ������ �� �� ASCII art
    Result := MakeASCIIfromBitmap(TmpBitmap, DonorFont, contrast, zoom, negative, CharacterSet);
    //
    FreeAndNil(TmpBitmap);
  end;
end;

end.
