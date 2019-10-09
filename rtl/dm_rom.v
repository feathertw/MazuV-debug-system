`define SET_GPR_FIXSIZEREG_ADDR  'h0d0
`define GET_GPR_FIXSIZEREG_ADDR  'h0e0
`define SET_CSR_FIXSIZE_ADDR     'h0f0
`define SET_CSR_FIXREG_ADDR      'h0f4
`define GET_CSR_FIXREG_ADDR      'h104
`define GET_CSR_FIXSIZE_ADDR     'h108
`define SET_MEM_FIXSIZE_ADDR     'h128
`define GET_MEM_FIXSIZE_ADDR     'h144

module dm_rom #(
        parameter ROM_SIZE = 'h0
) (
        input  [11:0] fix_reg,
        input  [ 1:0] fix_size,
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
                                `SET_GPR_FIXSIZEREG_ADDR :    assign rom[gvi/4] = (fix_size<<12)|(fix_reg<< 7) | {rom_file[gvi+3],rom_file[gvi+2],rom_file[gvi+1],rom_file[gvi+0]};
                                `GET_GPR_FIXSIZEREG_ADDR :    assign rom[gvi/4] = (fix_size<<12)|(fix_reg<<20) | {rom_file[gvi+3],rom_file[gvi+2],rom_file[gvi+1],rom_file[gvi+0]};

                                `SET_CSR_FIXREG_ADDR     :    assign rom[gvi/4] = (fix_reg<<20) | {rom_file[gvi+3],rom_file[gvi+2],rom_file[gvi+1],rom_file[gvi+0]};
                                `GET_CSR_FIXREG_ADDR     :    assign rom[gvi/4] = (fix_reg<<20) | {rom_file[gvi+3],rom_file[gvi+2],rom_file[gvi+1],rom_file[gvi+0]};

                                `SET_CSR_FIXSIZE_ADDR    :    assign rom[gvi/4] = (fix_size<<12) | {rom_file[gvi+3],rom_file[gvi+2],rom_file[gvi+1],rom_file[gvi+0]};
                                `GET_CSR_FIXSIZE_ADDR    :    assign rom[gvi/4] = (fix_size<<12) | {rom_file[gvi+3],rom_file[gvi+2],rom_file[gvi+1],rom_file[gvi+0]};
                                `SET_MEM_FIXSIZE_ADDR    :    assign rom[gvi/4] = (fix_size<<12) | {rom_file[gvi+3],rom_file[gvi+2],rom_file[gvi+1],rom_file[gvi+0]};
                                `GET_MEM_FIXSIZE_ADDR    :    assign rom[gvi/4] = (fix_size<<12) | {rom_file[gvi+3],rom_file[gvi+2],rom_file[gvi+1],rom_file[gvi+0]};
                                default:                      assign rom[gvi/4] =                  {rom_file[gvi+3],rom_file[gvi+2],rom_file[gvi+1],rom_file[gvi+0]};
                        endcase
                end
        endgenerate

endmodule
