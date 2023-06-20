unit unidad;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, StdCtrls, Buttons, UNodo,Udatos;

type

  { TFormGrafo }

  TFormGrafo = class(TForm)
    BotonFases: TBitBtn;
    BotonExportar: TBitBtn;
    LFASE: TLabel;
    ListBox1: TListBox;
    LTotalInteraciones: TLabel;
    LIteracion: TLabel;
    LFASE2: TLabel;
    pasadas: TMemo;
    Panel1: TPanel;
    Limiteiteraciones: TUpDown;
    DialogoSalvar: TSaveDialog;
    procedure BotonExportarClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormPaint(Sender: TObject);
    procedure LimiteiteracionesClick(Sender: TObject; Button: TUDBtnType);
    procedure Redibujar;
    procedure FormActivate(Sender: TObject);
    procedure QuitarTodasSelecciones;
    procedure Fase1;
    procedure Fase2;
    procedure Fase3;
    procedure Fase4;
    procedure FIN(estado:byte);
    procedure EscribeFase(cad:string);
    procedure EscribeFase2(cad:string);
    procedure EscribeIteracion(it:byte);
    procedure EscribeResultado(estado:byte);
    function ConstruyeVectoractual:string;
    procedure SalvarProceso;
    function EstaEnHistorico(vector:string):boolean;

  private

  public

  end;

var
  FormGrafo: TFormGrafo;
  NodosBit, NodosChequeo :TList;
  arcos:TList;
  NArcos:Word;
  seleccionado,chequeoseleccionado:byte;
  FASE, NODO, ElArco, iteracion :byte;
  ArcoAnterior:TArco;
  SeCumplenParidades:boolean;
  VectorActual:string;

implementation

{$R *.lfm}


{ TFormGrafo }



procedure TFormGrafo.FormActivate(Sender: TObject);
var
  fila, columna,cont, ancho, x:word;
  NB:TNodoBit;
  NC:TNodoChequeo;
  Arco:TArco;
  svectorerror :string;
begin
  top:=1;
  left:=1;
  width:=1024;
  height:=768;
  Limiteiteraciones.visible:=true;;
  iteracion:=1;
  BotonFases.Caption:='COMENZAR';
  LIteracion.Caption:='ITERACIÓN 0';
  FASE:=1;
  NODO:=1;
  LFASE.caption:='';
  LFASE2.Caption:='';
  seleccionado:=0;
  chequeoseleccionado:=0;
  ArcoAnterior:=nil;
  Listbox1.Items.Clear;
  pasadas.Lines.clear;
  BotonExportar.Visible:=false;

  NB:=TNodoBit.Create(Self,'');
  ancho:=NB.Width;
  NB.Destroy;

  x:=FormGrafo.Width-ancho*N;
  x:=round(x/(N+1));

  NodosBit:=TList.Create;
  SVectorError:='';
  for cont:=1 to N do
  begin
     NB:=TNodoBit.Create(self,'C'+IntToStr(cont));
     NB.left:=x+(cont-1)*ancho+(cont-1)*x;
     NB.Top:= 10;
     NB.Visible:=true;
     NB.valor:=VectorError[cont,1];
     SVectorError:=svectorerror+IntTostr(NB.valor);
     NodosBit.Add(NB);
  end;

  x:=FormGrafo.Width-ancho*M;
  x:=round(x/(M+1));


  NodosChequeo:=TList.Create;
  for cont:=1 to M do
  begin
     NC:=TNodoChequeo.Create(self,'F'+IntToStr(cont));
     NC.left:=x+(cont-1)*ancho+(cont-1)*x;
     NC.Top:= Panel1.top-NB.Height-10;;
     NC.Visible:=true;
     NodosChequeo.Add(NC);
  end;

   Arcos:=TList.Create;
   NArcos:=0;
   for fila:=1 to M do
   begin
      for columna:=1 to N do
      begin
         if H[fila,columna]=1 then
         begin
            arco:=TArco.Create(TNodoBit(NodosBit[columna-1]),TNodoChequeo(NodosChequeo[fila-1]));
            arcos.Add(arco);
            arco.Dibuja;
            inc(NArcos);
          end;
      end;
   end;
   Repaint;
   BotonFases.Enabled:=true;
   ListBox1.Items.Add('Se procesa el vector '+SVectorError);
   EscribeIteracion(1);
   EscribeFase('FASE 1. Nodos símbolo envían sus estados a nodos de chequeo');
end;


procedure TFormGrafo.Redibujar;
var
  cont:word;
  arco:TArco;
begin
   for cont:=1 to narcos do
   begin
      Arco:=TArco(arcos[cont-1]);
      arco.dibuja;
   end;

end;

procedure TFormGrafo.FormPaint(Sender: TObject);
begin
  Redibujar;
end;

procedure TFormGrafo.LimiteiteracionesClick(Sender: TObject; Button: TUDBtnType);
begin
    LTotalInteraciones.caption:='Límite de Iteraciones '+IntToSTR(Limiteiteraciones.Position) ;
end;

procedure TFormGrafo.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  While NodosBit.Count>0 do
  begin
     TNodoBit(NodosBit[0]).Destroy;
     NodosBit.Delete(0);
  end;
  NodosBit.Destroy;
  WHile NodosChequeo.Count>0 do
  begin
     TNodoChequeo(NodosChequeo[0]).Destroy;
     NodosChequeo.Delete(0);
  end;
  NodosChequeo.destroy;
  WHile Arcos.Count>0 do
  begin
     TArco(arcos[0]).Destroy;
     Arcos.Delete(0);
  end;
  Arcos.Destroy;
end;

procedure TFormGrafo.Button2Click(Sender: TObject);
begin
  BotonFases.Caption:='SIGUIENTE PASO';
  Limiteiteraciones.visible:=false;

  case fase of
     1:begin
        LIteracion.Caption:='ITERACIÓN '+IntToSTR(iteracion);;
        Fase1;
     end;
     2:begin
        Fase2;
     end;
     3:begin
        Fase3;
     end;
     4:begin
        Fase4;
     end;

     6:begin
        FIN(1);
     end;
  end;
end;

procedure TFormGrafo.SalvarProceso;
var
  fichero:text;
  cont:word;
begin
   Assignfile(fichero,DialogoSalvar.FileName);
   rewrite(fichero);
   for cont:= 0 to ListBox1.Items.Count-1 do
      writeln(fichero, ListBox1.Items[cont]);
   closefile(fichero);
end;

procedure TFormGrafo.BotonExportarClick(Sender: TObject);
begin
    if DialogoSalvar.Execute then
       SalvarProceso;
end;

procedure TFormGrafo.QuitarTodasSelecciones;
var
  cont:byte;

begin
  for cont:=0 to NodosBit.Count-1 do
  begin
     TNodoBit(NodosBit[cont]).ArcosMarcados:=false;
     TNodoBit(NodosBit[cont]).Activo:=false;
  end;

  for cont:=0 to NodosChequeo.Count-1 do
  begin
     TNodoChequeo(NodosChequeo[cont]).ArcosMarcados:=false;
     TNodoChequeo(NodosChequeo[cont]).Activo:=false;
  end;

end;

function TFormGrafo.ConstruyeVectoractual:string;
var
  cont:byte;
  NB:TNodoBit;
begin
     result:='';
     for cont:=1 to NodosBit.Count do
     begin
        NB:=TNodoBit(NodosBit[cont-1]);
        result:=result+NB.bits.Caption;
     end;
end;

function TFormGrafo.EstaEnHistorico(vector:string):boolean;
var
  cont:word;
begin
  result:=false;
  if pasadas.Lines.Count>1 then
      for cont:=0 to pasadas.Lines.Count-1 do  //En el memo se va insertando en la primera linea
          if cont<>0 then
             If vector=pasadas.Lines[cont] then   // Por lo que se empieza el testeo por la segunda
                result:=true; //para que no detecte el vector actual

end;

procedure TFormGrafo.Fase1;
var
  NB:TNodoBit;
begin
   VectorActual:=ConstruyeVectorActual;
   If (EstaEnHistorico(VectorActual))  then
      FIN(3)
   else
   begin
      NB:=TNodoBit(NodosBit[NODO-1]);
      EscribeFase2('NODO '+NB.Nombre+' envía '+NB.mensaje+' a '+NB.Chequeos);
      QuitarTodasSelecciones;
      NB.Envia;
      inc(nodo);
      if nodo>NodosBit.Count then
      begin
         Fase:=2;
         Nodo:=1;
         EscribeFase('FASE 2. Nodos de Chequeo calculan Paridad');
         SeCumplenParidades:=true;
      end;
   end;
end;

procedure TFormGrafo.Fase2;
var
  NC:TNodoChequeo;
begin
   NC:=TNodoChequeo(NodosChequeo[NODO-1]);
   QuitarTodasSelecciones;

   if Not NC.CalculaParidad then
   begin
      SeCumplenParidades:=false;
      EscribeFase2(NC.etiqueta.Caption+' '+'NO cumple paridad');
   end
   else
      EscribeFase2(NC.etiqueta.Caption+' '+'SI cumple paridad');

   inc(nodo);
   if nodo>NodosChequeo.Count then
   begin
      if SeCumplenParidades then
         Fase:=6
      else
      begin
         Fase:=3;
         EscribeFase('FASE 3. Envío de paridades alternativas.');
         Nodo:=1;
         ElArco:=1;
         QuitarTodasSelecciones;
      end;
   end;
end;

procedure TFormGrafo.Fase3;
var
  NC:TNodoChequeo;
  Arco:TArco;
  NB:TNodoBit;
  cont:byte;
begin
  NC:=TNodoChequeo(NodosChequeo[NODO-1]);
  QuitarTodasSelecciones;
  NC.Activo:=true;
  Arco:=TArco(NC.arcos[ElArco-1]);
  if ArcoAnterior<>nil then
  begin
      ArcoAnterior.color:=clblack;
      ArcoAnterior.dibuja;;
  end;
  Arco.color:=clred;
  Arco.Dibuja;
  if NC.CalculaParidadSinBit(ElArco) then
  begin
     NB:=NC.envia('0',ElArco);
     EscribeFase2('NODO '+NC.Nombre+' envía 0 a '+NB.Nombre);
  end
  else
  begin
     NB:=NC.envia('1',ElArco);
     EscribeFase2('NODO '+NC.Nombre+' envía 1 a '+NB.Nombre);
  end;


  ArcoAnterior:=Arco;
  inc(ElArco);
  if ElArco>NC.Arcos.count then
  begin
     inc(Nodo);
     ElArco:=1;
     if NODO>NodosChequeo.Count then
     begin
        Arco.color:=clBlack;
        Arco.Dibuja;

        EscribeFase('FASE 4. Nodos de Símbolo votan y estiman su nuevo valor.');
        fase:=4;
        NODO:=1;
        ElArco:=1;
        For cont:=1 to NodosChequeo.count do  //Se quita reborde de paridad, ya no sirve en fase 4
        begin
           NC:=TNodoChequeo(NodosChequeo[cont-1]);
           NC.QuitaMarcoParidad
        end;
     end;
  end;
end;

procedure TFormGrafo.Fase4;
var
  NB:TNodoBit;
  cont:byte;
  votacion : string;
begin
  NB:=TNodoBit(NodosBit[NODO-1]);
  QuitarTodasSelecciones;
  votacion:=NB.Vota;
  EscribeFase2('NODO '+NB.Nombre+' Votación --> '+votacion);
  inc(NODO);
  if NODO>NodosBit.Count then
  begin
     pasadas.Lines.insert(0,VectorActual);
     inc(iteracion);
     Fase:=1;
     NODO:=1;
     Elarco:=1;
     EscribeIteracion(iteracion);
     EscribeFase('FASE 1. Nodos símbolo envían sus estados a nodos de chequeo');
     for cont:=1 to NodosChequeo.count do
        TNodoChequeo(NodosChequeo[cont-1]).bits.Caption:=''; // vacio los bits de la iteracion anterior
     if iteracion>Limiteiteraciones.Position then
        FIN(2);

  end;
end;

procedure TFormGrafo.FIN(estado:byte);
begin
  EscribeResultado(estado);
  BotonFases.Enabled:=false;
  BotonExportar.Visible:=true;;
end;

procedure TFormGrafo.EscribeFase(cad:string);
begin
  lfase.Caption:=cad;
  ListBox1.Items.add(cad);
  ListBox1.ItemIndex:=ListBox1.Items.Count-1;;
end;

procedure TFormGrafo.EscribeFase2(cad:string);
begin
  LFASE2.Caption:=cad;
  ListBox1.Items.add(cad);
  ListBox1.ItemIndex:=ListBox1.Items.Count-1;;
end;

procedure TFormGrafo.EscribeIteracion(it:byte);
begin
   LIteracion.caption:=' ITERACIÓN '+IntToSTR(iteracion);
   ListBox1.items.add('ITERACIÓN '+IntToSTR(it));
   ListBox1.ItemIndex:=ListBox1.Items.Count-1;;
end;

procedure TFormGrafo.EscribeResultado(estado:byte);
begin
   case estado of
   1: begin
          Showmessage(' PROCESO FINALIZADO. se ha conseguido convergencia');
          Listbox1.items.Add(' PROCESO FINALIZADO. se ha conseguido convergencia');
      end;
   2: begin
          Showmessage('Se ha superado el límite de iteraciones sin converger');
          Listbox1.items.Add('Se ha superado el límite de iteraciones sin converger');
      end;
   3: begin
         ShowMessage('Se ha detectado un ciclo, el sistema no convergerá');
         Listbox1.items.Add('Se ha detectado un ciclo, el sistema no convergerá');
      end;
   end;
end;


end.

