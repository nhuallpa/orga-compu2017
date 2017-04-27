#!/bin/bash
echo "==========================COMIENZO PRUEBAS==============================="
echo "=============================TEST 1======================================"
echo "Test 1: Codificamos Man ingresando por stdin y devolviendo por stdout"
echo Man | ../tp0 -a encode
echo ""
echo "============================FIN TEST1===================================="
echo "========================================================================="
echo "=============================TEST 2======================================"
echo "Test 2: Codificamos y decodificamos Man, entrada stdin y salida stdout"
echo -n Man | ../tp0 | ../tp0 -a decode
echo ""
echo "============================FIN TEST2===================================="
echo "========================================================================="
echo "=============================TEST 3======================================"
echo "Test 3: Verificamos bit a bit"
echo xyz | ../tp0 | ../tp0 -a decode | od -t c
echo "============================FIN TEST3===================================="
echo "========================================================================="
echo "=============================TEST 4======================================"
echo "Test 4: Codificamos 1024 bytes y que no haya mas de 76 unidades de long."
      yes | head -c 1024 | ../tp0 -a encode
echo ""
echo "============================FIN TEST4===================================="
echo "========================================================================="
echo "=============================TEST 5======================================"
echo "Test 5: Verificamos que la cantidad de bytes decodificados, sea 1024."
      yes | head -c 1024 | ../tp0 -a encode | ../tp0 -a decode | wc -c
echo "============================FIN TEST5===================================="
echo "========================================================================="
echo "=============================TEST 6======================================"
echo "Test 6: Codifico el contenido del archivo de entrada y guardo en archivo"
echo "        de salida. Luego decodifico la salida de este archivo y lo mando"
echo "        a otro archivo de entrada."
../tp0 -i entrada.txt -o salida.txt -a encode
../tp0 -i salida.txt -o entrada2.txt -a decode
echo "============================FIN TEST6===================================="
echo "===========================FIN PRUEBAS==================================="
