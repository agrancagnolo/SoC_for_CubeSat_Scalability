# Archivos diseño digital:
Este archivo tiene como fin explicar el proceso de creacion de achivos, comparacion y visualizacion de las mismas por consola explicando asi la cantidad de archivos y los nombres representativos de cada uno. 

## Herramientas necesarias:
Primero que nada se especifican los comandos necesarios para realizar la  sintesis verificacion y visualizacion de ondas. Antes d e los comandos es necesario conocer las instalaciones necesarias para correr estos comandos las cuales son las siguientes.

### Icarus Verilog:
Se utiliza para compilar el diseño y simular el test bench. Los comandos de consola parasu instalacion son:

```sh
sudo apt-get update
sudo apt-get install iverilog
```
### GTKWave:
Es utilizado para leer un archivo generado por el compilador y poder visualizar todas las ondas simuladas y resultantes del testbench. Los comandos de consola para su instalacion son:

```sh
sudo apt-get install GTKWave
```

## Comandos:
Para compilar el diseño Verilog debemos contar con un archivo que sea nuestro bloque diseñado y un testbench el cual instancia nuestro modulo y le asigna algunos valores a las entradas. Para este ejemplo particular el diseño es el archivo `mi_modulo.v` y el testbench `tb_mi_modulo.v` 
 ```sh
iverilog -o testbench tb_mi_modulo.v mi_modulo.v
```

Ahora ejecutamos la simulacion y generamos el archivo de ondas con extension _.vcd_ con el siguiente comando.

```sh
vvp testbench
```
Una aclaracion que cabe destacar es que, debemos asegurarnos que en el archivo "tb_mi_modulo.v" debe especificarse que queremos que se cree el archivo .vcd para visualizar las ondas, esto se logra incluyendo estas lineas de codigo:

```verilog
initial begin
    $dumpfile("dump.vcd"); // Aqui se puede remplazar el nombre "dump" por uno representativo
    $dumpvars(0, tb_mi_modulo);
end
```

Si todo ha ido bien deberia crearse en el mismo directorio dos archivos, uno llamado `testbench` como resultado de la compilacion y el archivo `dump.vcd` de la ejecucion del testbench.

Por ultimo utilizamos la aplicacion **GTKWave** para visualizar als formas de onda, para ello, utilizamos el siguiente codigo:

```sh
gtkwave dump.vcd
```

Con esto deberia abrirse la aplicacion gtkwave donde como se observa en la siguiente imagen debemo clickear en testbench y seleccionar las señales que deseamos visualizar. 

![imagen GTKWave](https://github.com/CelinaBossa/CCD_SoC/blob/dise%C3%B1o_digital/OpenLane/desings/src/images/Screenshot%20from%202024-06-12%2019-54-11.png)


Aqui se debe seleccionar arriba a la izquierda donde dice **testbench** y selecionar abajo las señales que queramos ver representadas sus formas de onda.

## Resumen:
En resumen, teniendo en cuenta todas las consideraciones mencionadas, solo requerimos 3 lineas para poder verificar simular y visualizar las formas de onda de nuestro testbench. las cuales son las siguientes:
1. Compilar nuestro diseño
```sh
iverilog -o testbench tb_mi_bloque.v mi_modulo.v
```
2. Ejecutar la simualcion y generar archivo de ondas
```sh
vvp testbench
```
3. Visuaizacion de ondas con **GTKWave**
```sh
gtkwave dump.vcd
```






