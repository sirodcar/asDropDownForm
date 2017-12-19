unit uDrpForm;

interface

uses
{$IF CompilerVersion > 18}
  System.SysUtils, System.Classes, vcl.Forms, vcl.Controls, vcl.StdCtrls,
  System.Types, Winapi.Windows;
{$ELSE}
  SysUtils, Classes, Forms, Controls, StdCtrls, Types, Windows;
{$IFEND}

type
  TAnimationStyle = (asSlide, asBlend);

  TAsAnimation = class(TPersistent)
  private
    FAniActive: boolean;
    FAnimationStyle: TAnimationStyle;
    FAnimationDelay: Integer;
  protected

  public
    procedure Assign(Other: TPersistent); override;

  published
    property Active: boolean read FAniActive write FAniActive default true;
    property AnimationStyle: TAnimationStyle read FAnimationStyle
      write FAnimationStyle default asSlide;
    property AnimationDelay: Integer read FAnimationDelay write FAnimationDelay
      default 150;

  end;

  TDropDirection = (ddLeftToRight, ddCenter, ddRightToLeft);

  TasDropDownForm = class(TComponent)
  private
    FMyForm: TForm;
    FMyControl: TWinControl;
    FatoClose: boolean;
    FSpaceTop: SmallInt;
    FSpaceSide: SmallInt;
    FDropDownDirection: TDropDirection;
    FAnimation: TAsAnimation;
    procedure SetProps(const Value: TAsAnimation);
    { Private declarations }
  protected
    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure FormDeactivate(Sender: Tobject);
    procedure DoDropDown;
    procedure DoDropDownEx(AControl: TWinControl; AForm: TForm;
      ADropDownDirection: TDropDirection = ddLeftToRight);
  published
    property AutoCloseForm: boolean Read FatoClose write FatoClose default true;
    property Control: TWinControl Read FMyControl write FMyControl;
    property DropDownForm: TForm Read FMyForm write FMyForm;
    property SpaceSide: SmallInt Read FSpaceSide write FSpaceSide default 0;
    property SpaceTop: SmallInt Read FSpaceTop write FSpaceTop default 0;
    property DropDownDirection: TDropDirection Read FDropDownDirection
      write FDropDownDirection default ddLeftToRight;
    property FormAnimation: TAsAnimation read FAnimation write SetProps;

    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Anoirsoft', [TasDropDownForm]);
end;

{ TasDropDownForm }

constructor TasDropDownForm.Create(AOwner: TComponent);
begin

  inherited;

  // TasDropDownForm
  AutoCloseForm := true;

  // FAnimation
  FAnimation := TAsAnimation.Create;
  FAnimation.FAniActive := true;
  FAnimation.FAnimationDelay := 150;
  FAnimation.FAnimationStyle := asSlide;

end;

destructor TasDropDownForm.Destroy;
begin
  FAnimation.Free;
  inherited;
end;

procedure TasDropDownForm.DoDropDown;
var
  pt: TPoint;
begin
  if Assigned(FMyForm) and Assigned(FMyControl) then
  begin

    pt := FMyControl.ClientToScreen(Point(0, 0));

    if AutoCloseForm then
      FMyForm.OnDeactivate := FormDeactivate;

    if FMyForm.Visible then
    begin
      FMyForm.Visible := false;
    end;

    FMyForm.BorderStyle := bsNone;

    FMyForm.Top := pt.y + FMyControl.Height + FSpaceTop;

    case FDropDownDirection of
      ddLeftToRight:

        FMyForm.Left := pt.X + FSpaceSide;

      ddRightToLeft:

        FMyForm.Left := pt.X - FMyForm.Width + FMyControl.Width - FSpaceSide;

      ddCenter:
        FMyForm.Left := pt.X - (FMyForm.Width - FMyControl.Width) div 2;

    end;

    with FAnimation do
    begin
      if Active = true then
      begin
        case AnimationStyle of
          asSlide:
            AnimateWindow(FMyForm.Handle, FAnimationDelay, AW_VER_POSITIVE or
              AW_SLIDE);
          asBlend:
            AnimateWindow(FMyForm.Handle, FAnimationDelay,
              AW_BLEND or AW_SLIDE);
        end;
      end;
    end;

    FMyForm.Show;

  end;
end;

procedure TasDropDownForm.DoDropDownEx(AControl: TWinControl; AForm: TForm;
  ADropDownDirection: TDropDirection);
var
  pt: TPoint;
begin
  if Assigned(AControl) and Assigned(AForm) then
  begin

    pt := AControl.ClientToScreen(Point(0, 0));

    if AutoCloseForm then
      AForm.OnDeactivate := FormDeactivate;

    if AForm.Visible then
    begin
      AForm.Visible := false;
    end;

    AForm.BorderStyle := bsNone;
    AForm.Top := pt.y + AControl.Height + FSpaceTop;

    case ADropDownDirection of
      ddLeftToRight:

        AForm.Left := pt.X + FSpaceSide;

      ddRightToLeft:

        AForm.Left := pt.X - AForm.Width + AControl.Width - FSpaceSide;

      ddCenter:
        AForm.Left := pt.X - (AForm.Width - AControl.Width) div 2;

    end;

    with FAnimation do
    begin
      if Active then
      begin
        case AnimationStyle of
          asSlide:
            AnimateWindow(AForm.Handle, FAnimationDelay, AW_VER_POSITIVE or
              AW_SLIDE);
          asBlend:
            AnimateWindow(AForm.Handle, FAnimationDelay, AW_BLEND or AW_SLIDE);
        end;
      end;
    end;

    AForm.Show;

  end;

end;

procedure TasDropDownForm.FormDeactivate(Sender: Tobject);
begin

  with FAnimation do
  begin
    if Active then
    begin
      case AnimationStyle of
        asSlide:
          AnimateWindow((Sender as TForm).Handle, FAnimationDelay,
            AW_VER_NEGATIVE or AW_HIDE);
        asBlend:
          AnimateWindow((Sender as TForm).Handle, FAnimationDelay,
            AW_BLEND or AW_HIDE);
      end;
    end;
  end;

  (Sender as TForm).Close;
end;

procedure TasDropDownForm.SetProps(const Value: TAsAnimation);
begin
  FAnimation.Assign(Value);
end;

{ TAsAnimation }

procedure TAsAnimation.Assign(Other: TPersistent);
begin
  if Other is TAsAnimation then
  begin
    FAniActive := TAsAnimation(Other).FAniActive;
    FAnimationStyle := TAsAnimation(Other).FAnimationStyle;
  end
  else
    inherited
end;

end.
