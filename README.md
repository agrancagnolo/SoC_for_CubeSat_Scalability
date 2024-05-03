# Caravel Analog User

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![CI](https://github.com/efabless/caravel_user_project_analog/actions/workflows/user_project_ci.yml/badge.svg)](https://github.com/efabless/caravel_user_project_analog/actions/workflows/user_project_ci.yml) [![Caravan Build](https://github.com/efabless/caravel_user_project_analog/actions/workflows/caravan_build.yml/badge.svg)](https://github.com/efabless/caravel_user_project_analog/actions/workflows/caravan_build.yml)

---

## Analog Chip

The following project implements an analog circuit from which we want to extract samples with digital circuits, for example, schim triger, and then a counter so that they are later analyzed in the riscV. The riscV can then send the data to the outside of the chip by using the UART.

## Install PDK

    https://xschem.sourceforge.io/stefan/xschem_man/tutorial_xschem_sky130.html

| Paso                                       | Comando                                              |
|--------------------------------------------|------------------------------------------------------|
| fetch the repository with git:             | `git clone git://opencircuitdesign.com/open_pdks`    |
| ingreso al directorio                      | `cd open_pdks`                                       |
| configure the build                        | `./configure --enable-sky130-pdk`                    |
| make                                       | `make`                                               |
| make install                               | `sudo make install`                                  |

## Run magic

    export PDK_ROOT=/usr/local/share/pdks/
    sudo magic -T XR -rcfile $PDK_ROOT/sky130A/libs.tech/magic/sky130A.magicrc
    
    magic -rcfile ~/usr/local/share/pdk/sky130A/libs.tech/magic/sky130A.magicrc
    magic -rcfile ~/home/jona/Desktop/Proyecto_Final/caravan/dependencies/pdks/sky130A/libs.tech/magic/sky130A.magicrc


## Run xschem

    cp /usr/local/share/pdk/sky130B/libs.tech/xschem/xschemrc .
    xterm &
    xschem

## Run netgen

    ln -s /usr/share/pdk/sky130A/libs.tech/netgen/sky130A_setup.tcl setup.tcl
    netgen -batch lvs "../xschem/example_por.spice example_por" "../mag/example_por.spice example_por"
    




Refer to [README](docs/source/index.rst) for this sample project documentation. 
