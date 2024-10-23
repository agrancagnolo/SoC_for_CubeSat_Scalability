// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype wire 

module analog_signal_generator #(
    parameter       CICLOS_FORMAS_DE_ONDA = 8)
(   input wire      i_enable,
    input wire [31:0]  contador,
    input wire      i_clock, 
    output reg      o_adc_start_conversion
);

wire o_pixel_flag;
//FLAG DE GENERACION DE PULSOS DE CONVERISON
assign o_pixel_flag = ((contador >= (CICLOS_FORMAS_DE_ONDA*5)-1) && (contador< 2053*CICLOS_FORMAS_DE_ONDA));

//GENERACION SINCRONICA DEL PULSO
always @(posedge i_clock) begin
    if (~i_enable)
        o_adc_start_conversion = 0;
    else if(~o_pixel_flag) 
    	o_adc_start_conversion = 0;
    else if (o_pixel_flag)
        o_adc_start_conversion = ~o_adc_start_conversion;
end
endmodule

`default_nettype wire


