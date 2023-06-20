unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, Grids, ExtCtrls,
  StdCtrls, Buttons,unidad, Udatos, UMatriz;

type
  { TFormPrincipal }

  TFormPrincipal = class(TForm)
    AVISO2: TLabel;
    AVISO3: TLabel;
    panelmensaje: TBevel;
    panelYerror: TBevel;
    panelvectory: TBevel;
    lsindromebueno: TLabel;
    BotonBP: TBitBtn;
    lmensaje: TLabel;
    LSindromeRecibido: TLabel;
    LYRecibido: TLabel;
    lpalabra: TLabel;
    LCodigo: TLabel;
    AVISO1: TLabel;
    LWR: TLabel;
    LWC: TLabel;
    LN: TLabel;
    LM: TLabel;
    LK: TLabel;
    LG: TLabel;
    LH: TLabel;
    MainMenu1: TMainMenu;
    MatrizH: TStringGrid;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    DialogoAbrir: TOpenDialog;
    MatrizG: TStringGrid;
    Panel1: TPanel;
    procedure BotonBPClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure CambioCheckMensaje(Sender: TObject);
    procedure CambioCheckError(Sender: TObject);
    procedure CalculaDiferencia; // Diferencias en tre Vctor Y y Vector YERror
    procedure InicializarMensajes;
    procedure EscalarPantalla;
  private

  public

  end;

var
  FormPrincipal: TFormPrincipal;
  Mensaje,  MensajeError :array[1..15] Of TPanel;


implementation

{$R *.lfm}

{ TFormPrincipal }

procedure TFormPrincipal.FormCreate(Sender: TObject);
var
  cont:byte;
begin
  top:=1;
  left:=1;
  width:=1024;
  height:=768;
         // Se crean los objetos del mensaje y Mensaje erroneo
  for cont:=1 to 15 do
  begin
     mensaje[cont]:=TPanel.Create(Self);
     mensaje[cont].Parent:=self;
     mensaje[cont].Caption:=IntToStr(cont);
     mensaje[cont].top:=360;
     mensaje[cont].left:= 16+(cont-1)*29;
     mensaje[cont].Width:= 25;
     mensaje[cont].Height:=25;
     mensaje[cont].color:=clGray;
     mensaje[cont].font.color:=clWhite;
     mensaje[cont].visible:=false;
     mensaje[cont].OnClick:=@CambioCheckMensaje;

     MensajeError[cont]:=TPanel.Create(self);
     MensajeError[cont].Parent:=self;
     MensajeError[cont].Caption:=IntToStr(cont);
     MensajeError[cont].top:=520;
     MensajeError[cont].left:= 16+(cont-1)*29;
     mensajeError[cont].Width:= 25;
     mensajeError[cont].Height:=25;
     mensajeError[cont].color:=clGray;
     mensajeError[cont].font.color:=clWhite;
     mensajeError[cont].BevelInner:=bvRaised;
     mensajeError[cont].BevelOuter:=bvRaised;
     mensajeError[cont].visible:=false;
     MensajeError[cont].OnClick:=@CambioCheckError;
   end;
end;

procedure TFormPrincipal.BotonBPClick(Sender: TObject);
begin
  FormGrafo.ShowModal;
end;


procedure TFormPrincipal.CalculaDiferencia; // Diferencias en tre Vctor Y y Vector YERror
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


function Lectura(linea:string;var numero:word):boolean;
var
  error:integer;
begin
   linea:=copy(linea,7,length(linea)-6);
   val(linea,numero,error);
   if error>0 then
      result:=true
   else
      result:=false;
end;

procedure ErrorFichero;
begin
   ShowMessage('Error en el formato del fichero. El programa se detendrá');
   halt;
end;

procedure TFormPrincipal.MenuItem2Click(Sender: TObject);
var
  linea:string;
  fichero:text;
  fila, columna:word;
begin
   if DialogoAbrir.Execute then
   begin
      Limpiamatriz(H);
      Limpiamatriz(G);

      assignfile(fichero,DialogoAbrir.FileName);
      reset(fichero);
      readln(fichero,linea);

      // Se leen Parámetros

      if lectura(linea,Wr) then
         ErrorFichero;
      readln(fichero,linea);
      if lectura(linea,Wc) then
         ErrorFichero;
      readln(fichero,linea);
      if lectura(linea,N) then
         ErrorFichero;
      readln(fichero,linea);
      if lectura(linea,K) then
         ErrorFichero;
      readln(fichero,linea);
      if lectura(linea,M) then
         ErrorFichero;
      readln(fichero,linea);
      if lectura(linea,R) then
         ErrorFichero;

      LWR.Caption:='Wr (peso por filas) ........................ '+IntToSTR(wr);
      LWC.Caption:='Wc (peso por Columnas) ............ '+IntToSTR(wc);
      LN.Caption :='N (Longitud del código) ............. '+IntToSTR(N);
      LM.Caption :='M (Nº de filas de H) .................... '+IntToSTR(M);
      LK.Caption :='K (Longitud del mensaje)............. '+IntToSTR(K);

      // Se lee G
      MatrizG.ColCount:=k;
      MatrizG.RowCount:=n;

      LG.Caption:='Matriz G '+IntToSTR(N)+' x '+IntToSTR(K);

      readln(fichero,linea);

      for fila:=1 to N do
      begin
         readln(fichero,linea);
         for columna:=1 to K do
         begin
            val(linea[columna],G[fila,columna]);
            MatrizG.Cells[columna-1,fila-1]:=IntToSTR(G[fila,columna]);
         end;
      end;
      readln(fichero,linea);

      // Se lee H
      MatrizH.ColCount:=R;
      MatrizH.RowCount:=M;

      LH.Caption:='Matriz H '+IntToSTR(m)+' x '+IntToSTR(R);

      for fila:=1 to M do
      begin
         readln(fichero,linea);
         for columna:=1 to R do
         begin
            val(linea[columna],H[fila,columna]);
            MatrizH.Cells[columna-1,fila-1]:=IntToSTR(H[fila,columna]);
         end;
      end;
      EscalarPantalla;
      InicializarMensajes;
  end;
end;

procedure TFormPrincipal.MenuItem3Click(Sender: TObject);
begin
  close;
end;

procedure TFormPrincipal.CambioCheckMensaje(Sender: TObject);
var
  cont:byte;
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
   Lmensaje.Visible:=true;;

      //*********************************************************
      //                  Se Calcula y escribe Vector Y
      //*********************************************************


   VectorY:=Multiplica(G,VectorX,n,k,k,1); //  SE CALCULA VectorY = G x VectorX
   Normalizar(VectorY);
   lPalabra.Caption:='VECTOR Y (X x G)--> '+DameColumna(VectorY,1,N);
   lpalabra.Visible:=true;;
   //*********************************************************
   //                  Se Calcula Sindrome = H x VectorY
   //*********************************************************

   A:=Multiplica(H,VectorY,M,N,N,1); //  SE CALCULA VECTOR Y
   Normalizar(A);

   LSindromeBueno.Caption:='SÍNDROME --> '+DameColumna(A,1,M);
   lsindromebueno.Visible:=true;

   CalculaDiferencia;

end;

procedure TFormPrincipal.CambioCheckError(Sender: TObject);
var
  cont:byte;
  A :TMatriz;
begin
   Limpiamatriz(VectorError);
   LYRecibido.Caption:='VECTOR Y RECIBIDO --> ';
   LYRecibido.visible:=true;;
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
   LSindromeRecibido.visible:=true;;
   CalculaDiferencia;

end;


procedure TFormPrincipal.InicializarMensajes;
var
   cont:word;
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

procedure TFormPrincipal.EscalarPantalla;
var
   espacio:word;
   cont:byte;
begin
   lcodigo.visible:=true;
   lcodigo.Width:=panel1.width;;
   Panel1.Visible:=true;

   MatrizG.Width:=k*20+5;
   MatrizG.Height:=N*20+5;
   MatrizG.Visible:=true;

   LG.Visible:=true;;
   LG.width:=MatrizG.width;

   MatrizH.Width:=R*20+5;
   MatrizH.Height:=M*20+5;
   MatrizH.Visible:=true;

   LH.Visible:=true;;
   LH.width:=MatrizH.width;

  espacio:=round((1024-MatrizG.Width-Panel1.Width-MatrizH.width)/4);

  MatrizG.Left:=espacio;
  LG.Left:=Espacio;

  Panel1.left:=espacio*2+MatrizG.Width;
  LCodigo.Left:=Panel1.left;

  MatrizH.Left:=3*espacio+Panel1.Width+MatrizG.width;
  LH.Left:=MatrizH.left;

//  PanelMensaje.visible:=true;
  PanelMensaje.left:=espacio;
  PanelMensaje.width:=2*espacio+Panel1.Width+LH.Width;
  PanelMensaje.Top:=MatrizG.Top+MatrizG.Height+10;

//  PanelVectorY.visible:=true;
  PanelVectorY.left:=PanelMensaje.width;
  PanelVectorY.Width:=PanelMensaje.width;

//  PanelYError.visible:=true;;
  PanelYError.left:=PanelMensaje.width;
  PanelYError.Width:=PanelMensaje.width;
  for cont:=1 to 15 do
  begin
     mensaje[cont].left:=PanelMensaje.left + 16+(cont-1)*29;
     mensaje[cont].top:=PanelMensaje.top + 5;
  end;
  LMensaje.top:=mensaje[1].Top+mensaje[1].Height+5;
  LMensaje.Left:= PanelMensaje.left + 16;

  PanelVectorY.top:=PanelMensaje.top+PanelMensaje.Height+10;
  PanelVectorY.Left:=PanelMensaje.left;
  LPalabra.Left:=PanelVectorY.left+16;
  LPalabra.Top:=PanelVectorY.Top+5;
  LSindromeBueno.Left:=LPalabra.left;
  LSindromeBueno.top:=LPalabra.Top+LPalabra.Height+5;
  PanelVectorY.Height:=LPalabra.height+LSindromeBueno.height+10;
  PanelYError.left:=PanelVectorY.left;
  PanelYError.top:=PanelVectorY.top+PanelVectorY.height+5;

  for cont:=1 to 15 do
  begin
     MensajeError[cont].Left:=PanelYError.Left+16+(cont-1)*24;
     MensajeError[cont].top:=PanelYError.top+5;
  end;

  LYRecibido.left:=panelYError.left+16;
  LYRecibido.Top:=MensajeError[1].top+MensajeError[1].Height+5;
  LSindromeRecibido.left:=LYRecibido.left;
  LSindromeRecibido.top:=LYRecibido.top+LYRecibido.height;
  PanelYError.Height:=LYRecibido.height+LSindromeRecibido.height+Mensajeerror[1].height+15;

  PanelMensaje.Width:=MatrizH.left+matrizH.Width-MatrizG.left;
  PanelVectorY.Width:=PanelMensaje.width;
  PanelYError.Width:=PanelMensaje.width;

  Aviso1.caption:='<---- Introduzca mensaje a codificar';
  Aviso2.caption:='<---- Mensaje Codificado';
  Aviso3.Caption:='<---- Introduzca error en bits';;
  Aviso1.top:=mensaje[1].Top;
  Aviso2.Top:=PanelVectorY.top;
  Aviso3.Top:=MensajeError[1].top;
  aviso1.Left:=PanelMensaje.width+PanelMensaje.left-Aviso1.Width-5;
  aviso2.Left:=PanelMensaje.width+PanelMensaje.left-Aviso2.Width-5;
  aviso3.Left:=PanelMensaje.width+PanelMensaje.left-Aviso3.Width-5;

  self.Caption:='Belief Propagation - '+ ExtractFileName(DialogoAbrir.filename);
  BotonBP.visible:=true;
end;

end.

