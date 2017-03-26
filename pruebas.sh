#!/bin/bash
echo "========================================================================="
echo "Comienzo de pruebas"
echo "========================================================================="
echo "Test 1:"
./tp0 -a encode -i entrada.txt -o salida.txt
./tp0 -a decode -i salida.txt -o entrada2.txt

cat entrada.txt
cat entrada2.txt
echo ""

echo "========================================================================="
echo "Fin de pruebas"
echo "========================================================================="