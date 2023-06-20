unit UMensaje;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids,
  Buttons, ExtCtrls, RTTICtrls, Udatos, UMatriz;

type

  { TForm3 }

  TForm3 = class(TForm)
    LMensaje: TLabel;
    LPalabra: TLabel;
    LHY: TLabel;
    LSindromeBueno: TLabel;
    LYRecibido: TLabel;
    LSindromeRecibido: TLabel;
    procedure CambioCheckMensaje(Sender: TObject);
    procedure CambioCheckError(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CalculaDiferencia;
  private

  public

  end;



var
  Form3: TForm3;
  Mensaje,  MensajeError :array[1..15] Of TPanel;

implementation

{$R *.lfm}

{ TForm3 }

procedure TForm3.FormActivate(Sender: TObject);
var
   cont:word;
   i,j:byte;
begin
   Limpiamatriz(VectorX);
   Limpiamatriz(VectorY);

   if k > 15 then
   begin
      Showmessage('Esta aplicación solo funciona con mensajes <=15 bits');
      for cont:=1 to 15 do
         mensaje[cont].enabled:=false;
   end
   else
   begin
     for cont:=1 to 15 do
     begin
        if cont<=k then
           mensaje[cont].visible:=true
        else
           mensaje[cont].visible:=false;

        if cont<=N then
           MensajeError[cont].visible:=true
        else
           MensajeError[cont].visible:=false;

        mensaje[cont].color:=clgray;
        MensajeError[cont].Color:=clGray;
     end;
   end;
               // Se actualiza toda la pantalla
   CambioCheckMensaje(self);
   CambioCheckError(Self);
end;


procedure TForm3.CambioCheckMensaje(Sender: TObject);
var
  cont, seleccion:byte;
  A :TMatriz;
begin
   //*********************************************************
   //           Se Calcula y escribe VectorX
   //*********************************************************

   for cont:=1 to k do
      if TPanel(Sender)=Mensaje[cont] then
         if Mensaje[cont].Color=clgray then
             Mensaje[cont].Color:=clBlue
          else
             Mensaje[cont].Color:=clGray;

   for cont:=1 to k do
      if mensaje[cont].color=clgray then
      begin
         VectorX[cont,1]:=0
      end
      else
      begin
         VectorX[cont,1]:=1;
      end;

   LMensaje.Caption:='VECTOR X --> '+Damecolumna(VectorX,1,k);


      //*********************************************************
      //                  Se Calcula y escribe Vector Y
      //*********************************************************


   VectorY:=Multiplica(G,VectorX,n,k,k,1); //  SE CALCULA VectorY = G x VectorX
   Normalizar(VectorY);
   lPalabra.Caption:='VECTOR Y (X x G)--> '+DameColumna(VectorY,1,N);

   //*********************************************************
   //                  Se Calcula Sindrome = H x VectorY
   //*********************************************************

   A:=Multiplica(H,VectorY,M,N,N,1); //  SE CALCULA VECTOR Y
   Normalizar(A);

   LSindromeBueno.Caption:='SÍNDROME --> '+DameColumna(A,1,M);

   CalculaDiferencia;

end;

procedure TForm3.CambioCheckError(Sender: TObject);
var
  cont:byte;
  A :TMatriz;
begin
   Limpiamatriz(VectorError);
   LYRecibido.Caption:='VECTOR Y RECIBIDO --> ';

   for cont:=1 to N do
      if TPanel(Sender)=MensajeError[cont] then
         if MensajeError[cont].Color=clgray then
             MensajeError[cont].Color:=clBlue
          else
             MensajeError[cont].Color:=clGray;


   for cont:=1 to N do
      if MensajeError[cont].color=clblue then
      begin
         VectorError[cont,1]:=1;
      end
      else
      begin
         VectorError[cont,1]:=0;
      end;

   LYRecibido.Caption:='VECTOR Y RECIBIDO --> '+DameColumna(VectorError,1,N);

   A:=Multiplica(H,VectorError,M,N,N,1);
   Normalizar(A);

   LSindromeRecibido.Caption:='SÍNDROME ERROR--> '+DameColumna(A,1,M);

   CalculaDiferencia;

end;

procedure TForm3.CalculaDiferencia;
var
  cont:byte;
begin
   For cont:=1 to N do
      if VectorY[cont,1]=VectorError[cont,1] then
      begin
         MensajeError[cont].Font.Style:=[];
         MensajeError[cont].Font.Size:=8;
         MensajeError[cont].BevelColor:=clDefault;;
       end
       else
       begin
          MensajeError[cont].Font.Style:=[fsbold,fsUnderline];
          MensajeError[cont].Font.Size:=10;
          MensajeError[cont].BevelColor:=clRed;;
       end;
end;

procedure TForm3.FormCreate(Sender: TObject);
var
   cont:word;
begin
    for cont:=1 to 15 do
    begin
      mensaje[cont]:=TPanel.Create(self);
      mensaje[cont].Parent:=self;
      mensaje[cont].Caption:=IntToStr(cont);
      mensaje[cont].top:=30;
      mensaje[cont].left:= 16+(cont-1)*29;
      mensaje[cont].Width:= 25;
      mensaje[cont].Height:=25;
      mensaje[cont].color:=clGray;
      mensaje[cont].font.color:=clWhite;
      mensaje[cont].OnClick:=@CambioCheckMensaje;

      MensajeError[cont]:=TPanel.Create(self);
      MensajeError[cont].Parent:=self;
      MensajeError[cont].Caption:=IntToStr(cont);
      MensajeError[cont].top:=300;
      MensajeError[cont].left:= 16+(cont-1)*29;
      mensajeError[cont].Width:= 25;
      mensajeError[cont].Height:=25;
      mensajeError[cont].color:=clGray;
      mensajeError[cont].font.color:=clWhite;
      mensajeError[cont].BevelInner:=bvRaised;
      mensajeError[cont].BevelOuter:=bvRaised;
      MensajeError[cont].OnClick:=@CambioCheckError;

    end;
end;

end.

