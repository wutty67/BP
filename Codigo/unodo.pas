unit unodo;

{$mode ObjFPC}{$H+}


interface

uses
   Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ExtCtrls,
   StdCtrls;
   type

      TNodo= class (TCustomPanel)
         private
            FArcosMarcados:boolean;
            FActivo:boolean;
            procedure SetArcosMarcados(value:boolean);
            procedure SetActivo(value:boolean);
         protected
            simbolo:TShape;
         public
            etiqueta:Tlabel;
            bits:TLabel;
            Arcos:TList;
            property ArcosMarcados:boolean read FArcosMarcados write SetArcosMarcados;
            property Activo:boolean read FActivo write SetActivo;
            function Nombre:string;
            function mensaje:string;
            constructor Create(TheOwner: TComponent); override;
      end;

      TNodoBit= class(TNodo)
         private
              fvalor:byte;
              procedure SetValor(value:byte);
         public
            fparidad:boolean;
            constructor Create(TheOwner:TComponent;nombreNodo:string);
            property valor:byte read FValor write SetValor;
            Procedure Envia;
            procedure Recibe(bit: char);
            function Vota:string;
            function Chequeos:string;
      end;

      TNodoChequeo= class(TNodo)
         private
            FParidad:boolean;
            procedure SetParidad(value:boolean);
         public
            constructor Create(TheOwner: TComponent;nombreNodo:string);
            property paridad:boolean read fparidad write SetParidad;
            procedure Recibe(bit:char);
            function CalculaParidad:boolean;
            function CalculaParidadSinBit(bit:byte):boolean;
            function envia(bit:char;posicion:byte):TNodobit;
            procedure QuitaMarcoParidad;
      end;

      TArco=class
         public
            NB:TNodoBit;
            NC:TNodoChequeo;
            color:TColor;
            X1, Y1, X2, Y2:Word;
            UltimoEnvio:Char;
            constructor Create(B:TNodoBit;C:TNodoChequeo);
            procedure Dibuja;
      end;

implementation

   Constructor Tnodo.Create(TheOwner:TComponent);
   begin
      Inherited;
      parent:=TWinControl(TheOwner);
      visible:=false;
      Width:=24;
      Height:=55;
      BevelOuter:=bvNone;
      BevelInner:=bvRaised;
      simbolo:=TShape.Create(self);
      simbolo.Parent:=self;
      with simbolo do
      begin
         left:=1;
         width:=22;
         height:=22;
      end;
      etiqueta:=TLabel.Create(self);
      etiqueta.Parent:=Self;

      with etiqueta do
      begin
         left:=1;
         width:=22;
         height:=22;
         AutoSize:=false;
         Alignment:=taCenter;
      end;

      bits:=TLabel.Create(self);
      bits.Parent:=Self;
      with bits do
      begin
         left:=1;
         width:=22;
         height:=22;
         AutoSize:=false;
         Alignment:=taCenter;
         font.Size:=6;
      end;

      arcos:=TList.Create;
      ArcosMarcados:=false;
      activo:=false;
   end;

  procedure TNodo.SetArcosMarcados(value:boolean);
  var
    cont:word;
    arco:TArco;
  begin
     FArcosMarcados:=value;
     if arcos.Count>0 then
       for cont:=0 to arcos.Count-1 do
       begin
          arco:=TArco(arcos[cont]);
          if FArcosMarcados then
          begin
             arco.color:=clred;
             arco.Dibuja;
          end
          else
          begin
            arco.color:=clblack;
            arco.Dibuja;
          end;
       end;
  end;

  procedure TNodo.SetActivo(value:Boolean);
  begin
     FActivo:=value;
     if value then
     begin
        color:=clBlue;
        etiqueta.Font.Color:=clwhite;;
        bits.Font.Color:=clwhite;
     end
     else
     begin
       color:=clDefault;
       etiqueta.Font.Color:=clBlack;;
       bits.Font.Color:=clBlack;
     end;
  end;

  function TNodo.Nombre:string;
  begin
     result:=etiqueta.caption;
  end;

  function TNodo.Mensaje:string;
  begin
     result:=bits.Caption;
  end;

  Constructor TnodoBit.Create(TheOwner:TComponent;nombreNodo:string);
  begin
     Inherited create(TheOwner);
     simbolo.top:=30;
     simbolo.Shape:=stCircle;
     simbolo.Brush.Color:=clred;
     etiqueta.Caption:=nombreNodo;
     etiqueta.Top:=15;
     bits.Top:=1;
     bits.Caption:='';

  end;

  procedure TNodoBit.SetValor(value:byte);
  begin
     fvalor:=value;
     if value=1 then
        simbolo.brush.color:=clblue
     else
       simbolo.brush.color:=clgray;
     bits.Caption:=IntToSTR(value);
  end;

  Procedure TNodoBit.Envia;
  var
    cont:byte;
    NC:TNodoChequeo;
    arco:TArco;

  begin
     ArcosMarcados:=True;
     Activo:=true;
     for cont:=1 to Arcos.Count do
     begin
       Arco:=TArco(arcos[cont-1]);
       Arco.UltimoEnvio:=bits.Caption[1];
       NC:=TNodoChequeo(arco.NC);
       NC.Recibe(bits.Caption[1]);
     end;

  end;

  procedure TNodoBit.Recibe(bit:char);
  begin
     bits.Caption:=bits.caption+bit;
  end;

  function TNodoBit.Vota:string;
  var
     ceros, unos, cont:byte;
     cad:string;
  begin
     activo:=true;
     ceros:=0;
     unos:=0;
     cad:=bits.Caption;
     for cont:=1 to Length(cad) do
     begin
       if cad[cont]='0' then
          inc(ceros)
       else
          inc(unos);
     end;
     if ceros=unos then
     begin
        if valor=1 then
           bits.Caption:='1'
        else
           bits.caption:='0';
     end
     else
       if ceros>unos then
         bits.Caption:='0'
       else
         bits.Caption:='1';
     result:=bits.caption;
  end;

  function TNodoBit.Chequeos:string;
  var
     cont:byte;
     NC:TNodoChequeo;
     arco:TArco;
  begin
     result:='';
     for cont:=1 to arcos.Count do
     begin
       arco:=TArco(arcos[cont-1]);
       NC:=TNodoChequeo(arco.NC);
       result:=result+' '+NC.etiqueta.Caption;
     end;
  end;

  Constructor TnodoChequeo.Create(TheOwner:TComponent;nombreNodo:string);
  begin
     Inherited create(TheOwner);
     simbolo.top:=1;
     simbolo.Shape:=stRectangle;
     simbolo.Brush.Color:=clBlue;
     etiqueta.Caption:=nombreNodo;
     etiqueta.top:=25;
     bits.Top:=40;
  end;

  procedure TNodoChequeo.Recibe(bit:char);
  begin
     bits.Caption:=bits.Caption+bit;
  end;

  function TNodoChequeo.envia(bit:char;posicion:byte):TNodoBit;
  var
     NB:TNodoBit;
     arco:TArco;
  begin
     arco:=TArco(arcos[posicion-1]);
     NB:=TNodoBit(arco.NB);
     NB.Recibe(bit);
     result:=NB;
  end;

  procedure TNodoChequeo.SetParidad(value:boolean);
  begin
     fParidad:=value;
     if value then
        BevelColor:=clgreen
     else
        BevelColor:=clred;
  end;

  function TNodoChequeo.CalculaParidadSinBit(bit:byte):boolean;
  var
     almacen,cont:byte;
     cad:string;
  begin
     almacen:=0;
     cad:=bits.Caption;
     for cont:=1 to Length(cad) do
       if bit<>cont then
         if cad[cont]='1' then
            if almacen=1 then
               almacen:=0
            else
               almacen:=1;
     if almacen=0 then
        paridad:=true
     else
        paridad:=false;
     result:=paridad;
  end;

  function TNodoChequeo.CalculaParidad:boolean;
  var
     almacen,cont:byte;
     cad:string;
  begin
     activo:=true;
     almacen:=0;
     cad:=bits.Caption;
     for cont:=1 to Length(cad) do
       if cad[cont]='1' then
          if almacen=1 then
             almacen:=0
          else
             almacen:=1;
     if almacen=0 then
        paridad:=true
     else
        paridad:=false;
     result:=paridad;
  end;

  procedure TNodoChequeo.QuitaMarcoParidad;
  begin
     BevelColor:=clDefault;
  end;

  Constructor TArco.Create(B:TNodoBit;C:TNodoChequeo);
  begin
     NB:=B;
     NC:=C;
     B.Arcos.Add(self);
     C.Arcos.add(self);
     x1:=b.Left+round(b.Width/2);
     y1:=b.top+b.height;;
     x2:=c.Left+round(c.Width/2);
     y2:=c.top;
     color:=clBlack;
  end;

  procedure TArco.Dibuja;
  var
     NodoBit:TNodoBit;
  begin
     NodoBit:=TNodoBit(NB);
     TForm(NodoBit.Owner).Canvas.Pen.color:=color;
     TForm(NodoBit.Owner).canvas.Line(X1,Y1,x2,y2);
  end;

end.

