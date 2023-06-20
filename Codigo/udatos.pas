Unit  UDatos;
{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type

  TMatriz = array[1..100] of array [1..100] of shortint;

var    // Variables Globales
 Wr, Wc, n,k,r,m :word;

 H, G : TMatriz;
 VectorX, VectorY, VectorError :TMatriz;

 implementation
 begin
 end.
