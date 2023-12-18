# Flip Flop Pinball

## Organização dos arquivos
* `cad`: modelos 3D para corte a laser do MDF, e impressão 3D dos flippers;
* `esp`: código programado para o ESP32, não inclui o arquivo `wifi_config.h` com as configurações da rede local;
* `src`: códigos fonte em `.vhd` da entidade `flip_flop_pinball`;
* `ui`: código pygame da interface para computador.

## To load it in Quartus:

* Open `.qpf` file in Quartus;
* Navigate to  `tools > tcl scripts`, select `flip_flop_pinball.tcl` and click `run`.

Now all pin assignments have been loaded and the project can be compiled and synthesized.
If you modify the pin assignments and want to push them:

* Navigate to `Project > Generate tcl files for project`, make sure "Include default assignments is  selected", and overwrite the original `flip_flop_pinball.tcl` by clicking `OK`.
