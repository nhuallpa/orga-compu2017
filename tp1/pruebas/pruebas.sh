#!/bin/bash
echo "==========================COMIENZO PRUEBAS==============================="
echo "=============================TEST 1======================================"
echo "Test 1: Codificamos Man ingresando por stdin y devolviendo por stdout"
echo Man | ./tp1 -a encode
echo ""
echo "============================FIN TEST1===================================="
echo "========================================================================="
echo "=============================TEST 2======================================"
echo "Test 2: Codificamos y decodificamos Man, entrada stdin y salida stdout"
echo -n Man | ./tp1 | ./tp1 -a decode | od -t c
echo ""
echo "============================FIN TEST2===================================="
echo "========================================================================="
echo "=============================TEST 3======================================"
echo "Test 3: Verificamos bit a bit"
echo xyz | ./tp1 | ./tp1 -a decode | od -t c
echo "============================FIN TEST3===================================="
echo "========================================================================="
echo "=============================TEST 4======================================"
echo "Test 4: Codificamos 1024 bytes y que no haya mas de 76 unidades de long."
      yes | head -c 1024 | ./tp1 -a encode | od -t c
echo ""
echo "============================FIN TEST4===================================="
echo "========================================================================="
echo "=============================TEST 5======================================"
echo "Test 5: Verificamos que la cantidad de bytes decodificados, sea 1024."
      export ORI=archivo_orig_yes.txt &&
      export RES=archivo_result_yes.txt &&
      yes | head -c 1024 | tee $ORI | ./tp1 | ./tp1 -a decode | tee $RES | wc -c && 
      diff -s $ORI $RES && 
      cat $RES | od -t c
echo "============================FIN TEST5===================================="
echo "========================================================================="
echo "=============================TEST 6======================================"
echo "Test 6: Codifico el contenido del archivo de entrada y guardo en archivo"
echo "        de salida. Luego decodifico la salida de este archivo y lo mando"
echo "        a otro archivo de entrada."
./tp1 -i entrada.txt -o salida.txt -a encode 
./tp1 -i salida.txt -o entrada2.txt -a decode
diff -s entrada.txt entrada2.txt 
echo "============================FIN TEST6===================================="
echo "=============================TEST 7======================================"
echo "Test 7: Codifico saltos de linea"
      export ORI=archivo_orig_esc.txt &&
      export RES=archivo_result_esc.txt &&
      echo -ne 123tzyx\\t\\n | tee $ORI | ./tp1 -a encode | ./tp1 -a decode | tee $RES | od -c &&
      diff -s $ORI $RES

echo "============================FIN TEST7===================================="
echo "=============================TEST 8======================================"
echo "Test 7: Codifico y decodifico una imagen. Prueba de binarios"
	  ./tp1 -a encode -i linux-icon.png | ./tp1 -a decode -o linux-icon.png.b64 &&
      diff -s linux-icon.png linux-icon.png.b64

echo "============================FIN TEST8===================================="
echo "===========================FIN PRUEBAS==================================="
