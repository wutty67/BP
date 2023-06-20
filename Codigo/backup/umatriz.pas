unit UMatriz;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;


type
    TMatriz = array[1..100] of array [1..100] of shortint;

 procedure Limpiamatriz(var A:TMatriz);
 function Multiplica (var A, B: TMatriz;filas1,columnas1,filas2,columnas2:byte):TMatriz;
 function Damefila (var A:TMatriz;fila,largo:byte):string;
 function Damecolumna(var A:TMatriz;columna, largo:byte):string;
 function Trasponer (var A:TMatriz):TMatriz;
 procedure Normalizar(var A :TMatriz);

implementation

procedure Limpiamatriz(var A:TMatriz);
var
 i,j:byte;
begin
   for i:=1 to 100 do
      for j:=1 to 100 do
         A[i,j]:=-1;
end;


function Multiplica (var A, B: TMatriz;filas1,columnas1,filas2,columnas2:byte):TMatriz;
var
   f1,c1,c2:byte;
   almacen:integer;
begin
   Limpiamatriz(result);
   for c2:=1 to columnas2 do
   begin
     for f1:=1 to filas1 do
     begin
       almacen:=0;
       for c1:=1 to columnas1 do
       begin
          inc(almacen, A[f1,c1]*B[c1,c2]);
       end;
       result[f1,c2]:=almacen;
     end;
   end;
end;

function Damefila (var A:TMatriz;fila,largo:byte):string;
var
   cont:byte;
begin
   result:='';
   for cont :=1 to largo do
      result:=result+IntToSTR(A[fila,cont])+' ';
end;

function Damecolumna(var A:TMatriz;columna, largo:byte):string;
var
   cont:byte;
begin
   result:='';
   for cont :=1 to largo do
      result:=result+IntToSTR(A[cont,columna])+' ';
end;

function Trasponer (var A:TMatriz):TMatriz;
var
   i,j:byte;
begin
   for i:=1 to 100 do
      for j:=1 to 100 do
         result[j,i]:=A[i,j];
end;

Procedure Normalizar(var A :TMatriz);
var
   i,j, valor:byte;
begin
   for i:=1 to 100 do
      for j:=1 to 100 do
         while A[i,j]>1 do
            dec(A[i,j],2);
end;



end.

