`define FIX_SET_GPR_ADDR 'h11c //zero
`define FIX_GET_GPR_ADDR 'h154 //zero
`define FIX_SET_CSR_ADDR 'h17c //ustatus
`define FIX_GET_CSR_ADDR 'h1a0 //ustatus
`define FIX_SET_MEM_ADDR 'h1c4 //sb
`define FIX_GET_MEM_ADDR 'h1e0 //lb

module dm_rom #(
        parameter ROM_SIZE = 'h400
) (
        input  [11:0] instr_fix,
        input  [ 9:0] addr,
        output [31:0] rdata
);
        assign rdata = rom[addr[9:2]];


        reg  [ 7:0] rom_file [0:ROM_SIZE-1];
        wire [31:0] rom      [0:ROM_SIZE/4-1];
        initial begin
                $readmemh("debug/src/dm_rom.hex", rom_file);
        end

        genvar gvi;
        generate
                for (gvi = 0; gvi < ROM_SIZE; gvi = gvi + 4) begin
                        case(gvi)
                                `FIX_SET_GPR_ADDR: assign rom[gvi/4] = (instr_fix<< 7) | {rom_file[gvi+3],rom_file[gvi+2],rom_file[gvi+1],rom_file[gvi+0]};
                                `FIX_GET_GPR_ADDR: assign rom[gvi/4] = (instr_fix<<20) | {rom_file[gvi+3],rom_file[gvi+2],rom_file[gvi+1],rom_file[gvi+0]};
                                `FIX_SET_CSR_ADDR: assign rom[gvi/4] = (instr_fix<<20) | {rom_file[gvi+3],rom_file[gvi+2],rom_file[gvi+1],rom_file[gvi+0]};
                                `FIX_GET_CSR_ADDR: assign rom[gvi/4] = (instr_fix<<20) | {rom_file[gvi+3],rom_file[gvi+2],rom_file[gvi+1],rom_file[gvi+0]};
                                `FIX_SET_MEM_ADDR: assign rom[gvi/4] = (instr_fix<<12) | {rom_file[gvi+3],rom_file[gvi+2],rom_file[gvi+1],rom_file[gvi+0]};
                                `FIX_GET_MEM_ADDR: assign rom[gvi/4] = (instr_fix<<12) | {rom_file[gvi+3],rom_file[gvi+2],rom_file[gvi+1],rom_file[gvi+0]};
                                default:           assign rom[gvi/4] =                   {rom_file[gvi+3],rom_file[gvi+2],rom_file[gvi+1],rom_file[gvi+0]};
                        endcase
                end
        endgenerate

endmodule
