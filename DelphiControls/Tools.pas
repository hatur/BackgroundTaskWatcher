unit Tools;

{by Gustavo Daud (Submited on 21 May 2006 )
Use this method to rotate RGB and RGB Alpha 'Portable Network Graphics' Images using a smooth antialiased algorithm in order to get much better results.
Note: Part of this code was based on JansFreeware code [http://jansfreeware.com/]
This is only possible when using the 1.56 library version.}

{$HINTS ON}
{$WARNINGS ON}

interface

uses
  System.Types, System.Classes, System.SysUtils, Vcl.Imaging.Pngimage;

procedure SmoothRotate(var aPng: TPNGImage; Angle: Extended);

implementation

{Smooth rotate a png object}
{this is bad, hatur}
procedure SmoothRotate(var aPng: TPNGImage; Angle: Extended);

  {Supporting functions}
  function TrimInt(i, Min, Max: Integer): Integer;
  begin
    if      i>Max then Result:=Max
    else if i<Min then Result:=Min
    else               Result:=i;
  end;
  function IntToByte(i:Integer):Byte;
  begin
    if      i>255 then Result:=255
    else if i<0   then Result:=0
    else               Result:=i;
  end;
  function Min(A, B: Double): Double;
  begin
    if A < B then Result := A else Result := B;
  end;
  function Max(A, B: Double): Double;
  begin
    if A > B then Result := A else Result := B;
  end;
  function Ceil(A: Double): Integer;
  begin
    Result := Integer(Trunc(A));
    if Frac(A) > 0 then
      Inc(Result);
  end;

  {Calculates the png new size}
  function newsize: tsize;
  var
    fRadians: Extended;
    fCosine, fSine: Double;
    fPoint1x, fPoint1y, fPoint2x, fPoint2y, fPoint3x, fPoint3y: Double;
    fMinx, fMiny, fMaxx, fMaxy: Double;
  begin
    {Convert degrees to radians}
    fRadians := (2 * PI * Angle) / 360;

    fCosine := abs(cos(fRadians));
    fSine := abs(sin(fRadians));

    fPoint1x := (-apng.Height * fSine);
    fPoint1y := (apng.Height * fCosine);
    fPoint2x := (apng.Width * fCosine - apng.Height * fSine);
    fPoint2y := (apng.Height * fCosine + apng.Width * fSine);
    fPoint3x := (apng.Width * fCosine);
    fPoint3y := (apng.Width * fSine);

    fMinx := min(0,min(fPoint1x,min(fPoint2x,fPoint3x)));
    fMiny := min(0,min(fPoint1y,min(fPoint2y,fPoint3y)));
    fMaxx := max(fPoint1x,max(fPoint2x,fPoint3x));
    fMaxy := max(fPoint1y,max(fPoint2y,fPoint3y));

    Result.cx := ceil(fMaxx-fMinx);
    Result.cy := ceil(fMaxy-fMiny);
  end;
type
 TFColor  = record b,g,r:Byte end;
var
Top, Bottom, Left, Right, eww,nsw, fx,fy, wx,wy: Extended;
cAngle, sAngle:   Double;
xDiff, yDiff, ifx,ify, px,py, ix,iy, x,y, cx, cy: Integer;
nw,ne, sw,se: TFColor;
anw,ane, asw,ase: Byte;
P1,P2,P3:Pbytearray;
A1,A2,A3: pbytearray;
dst: TPNGImage;
IsAlpha: Boolean;
new_colortype: Integer;
begin
  {Only allows RGB and RGBALPHA images}
  if not (apng.Header.ColorType in [COLOR_RGBALPHA, COLOR_RGB]) then
    raise Exception.Create('Only COLOR_RGBALPHA and COLOR_RGB formats' +
    ' are supported');
  IsAlpha := apng.Header.ColorType in [COLOR_RGBALPHA];
  if IsAlpha then new_colortype := COLOR_RGBALPHA else
    new_colortype := COLOR_RGB;

  {Creates a copy}
  dst := tpngobject.Create;
  with newsize do
    dst.createblank(new_colortype, 8, cx, cy);
  cx := dst.width div 2; cy := dst.height div 2;

  {Gather some variables}
  Angle:=angle;
  Angle:=-Angle*Pi/180;
  sAngle:=Sin(Angle);
  cAngle:=Cos(Angle);
  xDiff:=(Dst.Width-apng.Width)div 2;
  yDiff:=(Dst.Height-apng.Height)div 2;

  {Iterates over each line}
  for y:=0 to Dst.Height-1 do
  begin
    P3:=Dst.scanline[y];
    if IsAlpha then A3 := Dst.AlphaScanline[y];
    py:=2*(y-cy)+1;
    {Iterates over each column}
    for x:=0 to Dst.Width-1 do
    begin
      px:=2*(x-cx)+1;
      fx:=(((px*cAngle-py*sAngle)-1)/ 2+cx)-xDiff;
      fy:=(((px*sAngle+py*cAngle)-1)/ 2+cy)-yDiff;
      ifx:=Round(fx);
      ify:=Round(fy);

      {Only continues if it does not exceed image boundaries}
      if(ifx>-1)and(ifx<apng.Width)and(ify>-1)and(ify<apng.Height)then
      begin
        {Obtains data to paint the new pixel}
        eww:=fx-ifx;
        nsw:=fy-ify;
        iy:=TrimInt(ify+1,0,apng.Height-1);
        ix:=TrimInt(ifx+1,0,apng.Width-1);
        P1:=apng.scanline[ify];
        P2:=apng.scanline[iy];
        if IsAlpha then A1 := apng.alphascanline[ify];
        if IsAlpha then A2 := apng.alphascanline[iy];
        nw.r:=P1[ifx*3];
        nw.g:=P1[ifx*3+1];
        nw.b:=P1[ifx*3+2];
        if IsAlpha then anw:=A1[ifx];
        ne.r:=P1[ix*3];
        ne.g:=P1[ix*3+1];
        ne.b:=P1[ix*3+2];
        if IsAlpha then ane:=A1[ix];
        sw.r:=P2[ifx*3];
        sw.g:=P2[ifx*3+1];
        sw.b:=P2[ifx*3+2];
        if IsAlpha then asw:=A2[ifx];
        se.r:=P2[ix*3];
        se.g:=P2[ix*3+1];
        se.b:=P2[ix*3+2];
        if IsAlpha then ase:=A2[ix];


        {Defines the new pixel}
        Top:=nw.b+eww*(ne.b-nw.b);
        Bottom:=sw.b+eww*(se.b-sw.b);
        P3[x*3+2]:=IntToByte(Round(Top+nsw*(Bottom-Top)));
        Top:=nw.g+eww*(ne.g-nw.g);
        Bottom:=sw.g+eww*(se.g-sw.g);
        P3[x*3+1]:=IntToByte(Round(Top+nsw*(Bottom-Top)));
        Top:=nw.r+eww*(ne.r-nw.r);
        Bottom:=sw.r+eww*(se.r-sw.r);
        P3[x*3]:=IntToByte(Round(Top+nsw*(Bottom-Top)));

        {Only for alpha}
        if IsAlpha then
        begin
          Top:=anw+eww*(ane-anw);
          Bottom:=asw+eww*(ase-asw);
          A3[x]:=IntToByte(Round(Top+nsw*(Bottom-Top)));
        end;

      end;
    end;
  end;

  apng.assign(dst);
  dst.Free;
end;

end.
