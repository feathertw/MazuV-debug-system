module dm #(
	parameter NUM_HART = 1
) (
        output            interrupt,
        input             dmi_valid,
        output reg        dmi_ready,
        input             dmi_write,
        input [ 6:0]      dmi_addr,
        input [31:0]      dmi_wdata,
        output reg [31:0] dmi_rdata,

	input             bus_valid,
	output reg        bus_ready,
	input             bus_write,
	input   [19:2]    bus_addr,
	input   [31:0]    bus_wdata,
	output reg [31:0] bus_rdata,

	input resetn,
	input clk
);

        `include "debug/rtl/header.v"

        integer i;
        localparam ROM_SIZE = 'h400;
        localparam ROM_SET_GPR_ADDR = 'h120;
        localparam ROM_GET_GPR_ADDR = 'h158;
        localparam ROM_SET_CSR_ADDR = 'h180;
        localparam ROM_GET_CSR_ADDR = 'h1a4;
        localparam ROM_SET_MEM_ADDR = 'h1c8;
        localparam ROM_GET_MEM_ADDR = 'h1e4;


        reg  [ 7:0] rom_file [0:ROM_SIZE-1];
        wire [31:0] rom      [0:ROM_SIZE/4-1];
        initial begin
                $readmemh("debug/src/dm_rom.hex", rom_file);
        end

        reg [11:0] specific_reg;
        genvar gi;
        generate
                for (gi = 0; gi < ROM_SIZE; gi = gi + 4) begin
                        if (gi == ROM_SET_GPR_ADDR) begin
                                assign rom[gi/4] = (specific_reg<<7) | {rom_file[gi+3],rom_file[gi+2],rom_file[gi+1],rom_file[gi+0]};
                        end else if (gi == ROM_GET_GPR_ADDR || gi == ROM_SET_CSR_ADDR || gi == ROM_GET_CSR_ADDR) begin
                                assign rom[gi/4] = (specific_reg<<20) | {rom_file[gi+3],rom_file[gi+2],rom_file[gi+1],rom_file[gi+0]};
                        end else if (gi == ROM_SET_MEM_ADDR || gi == ROM_GET_MEM_ADDR) begin
                                assign rom[gi/4] = (specific_reg<<12) | {rom_file[gi+3],rom_file[gi+2],rom_file[gi+1],rom_file[gi+0]};
                        end else begin
                                assign rom[gi/4] = {rom_file[gi+3],rom_file[gi+2],rom_file[gi+1],rom_file[gi+0]};
                        end
                end
        endgenerate

        wire dmi_match = dmi_valid && dmi_ready;
        assign interrupt = haltreq ;

        reg [31:0] dm_register [0:2**7-1];
        always @* begin
                for (i=0; i<2**7; i=i+1) begin
                        dm_register[i] = 32'h0;
                end
                dm_register[DMI_ADDR_DATA0] = data0;
                dm_register[DMI_ADDR_DATA1] = data1;
                dm_register[DMI_ADDR_DMCONTROL][`HALTREQ_RANGE]  = haltreq;
                dm_register[DMI_ADDR_DMCONTROL][`DMACTIVE_RANGE] = dmactive;
                dm_register[DMI_ADDR_DMSTATUS][`ALLRUNNING_RANGE] = ~hart_halt[hartsel];
                dm_register[DMI_ADDR_DMSTATUS][`ANYRUNNING_RANGE] = ~hart_halt[hartsel];
                dm_register[DMI_ADDR_DMSTATUS][`ALLHALTED_RANGE]  =  hart_halt[hartsel];
                dm_register[DMI_ADDR_DMSTATUS][`ANYHALTED_RANGE]  =  hart_halt[hartsel];
        end

        reg [`HARTSEL_RANGE] hartsel;

        reg [`HALTREQ_RANGE]  haltreq;
        reg [`DMACTIVE_RANGE] dmactive;
        always @(posedge clk) begin if(!resetn) begin
                        dmactive <= `DMACTIVE_WIDTH'h0;
                end else if(dmi_match_write(DMI_ADDR_DMCONTROL)) begin
                        dmactive <= dmi_wdata[`DMACTIVE_RANGE];
                end
        end
        always @(posedge clk) begin
                if(!resetn || !dmactive) begin
                        haltreq <= `HALTREQ_WIDTH'h0;
                end else if(dmi_match_write(DMI_ADDR_DMCONTROL)) begin
                        haltreq <= dmi_wdata[`HALTREQ_RANGE];
                end
        end
        always @(posedge clk) begin
                if(!resetn || !dmactive) begin
                        hartsel <= `HARTSEL_WIDTH'h0;
                end else if(dmi_match_write(DMI_ADDR_DMCONTROL)) begin
                        hartsel <= {dmi_wdata[`HARTSELHI_RANGE],dmi_wdata[`HARTSELLO_RANGE]};
                end
        end

        // dm_request: [31]==valid, [25:20]==number, [19:0]==hartid
        reg [`DMREG_RANGE] dm_request;
        always @(posedge clk) begin
                if(!resetn) begin
                        dm_request <= 0;
                end else if(dmi_match_write(DMI_ADDR_DMCONTROL) && dmi_wdata[`RESUMEREQ_RANGE]) begin
                        dm_request <= dm_request_next(REQUEST_NUMBER_RESUME);
                end else if(dmi_match_write(DMI_ADDR_COMMAND)) begin
                        if(dmi_wdata[`CMDTYPE_RANGE]==CMDTYPE_ACCESSREG && dmi_wdata[`TRANSFER_RANGE]) begin
                                if(REGNO_FPR_BASE <= dmi_wdata[`REGNO_RANGE]) begin

                                end else if(REGNO_GPR_BASE <= dmi_wdata[`REGNO_RANGE]) begin
                                        specific_reg <= dmi_wdata[4:0];
                                        if(dmi_wdata[`REGNO_RANGE]==REGNO_GPR_BASE+GPR_S0) begin
                                                if(dmi_wdata[`WRITE_RANGE])  dm_request <= dm_request_next(REQUEST_NUMBER_SET_S0);
                                                else                         dm_request <= dm_request_next(REQUEST_NUMBER_GET_S0);
                                        end else if(dmi_wdata[`REGNO_RANGE]==REGNO_GPR_BASE+GPR_S1) begin
                                                if(dmi_wdata[`WRITE_RANGE])  dm_request <= dm_request_next(REQUEST_NUMBER_SET_S1);
                                                else                         dm_request <= dm_request_next(REQUEST_NUMBER_GET_S1);
                                        end else begin
                                                if(dmi_wdata[`WRITE_RANGE])  dm_request <= dm_request_next(REQUEST_NUMBER_SET_GPR);
                                                else                         dm_request <= dm_request_next(REQUEST_NUMBER_GET_GPR);
                                        end
                                end else begin
                                        specific_reg <= dmi_wdata[11:0];
                                        if(dmi_wdata[`REGNO_RANGE]==REGNO_CSR_BASE+CSR_DPC) begin
                                                if(dmi_wdata[`WRITE_RANGE])  dm_request <= dm_request_next(REQUEST_NUMBER_SET_DPC);
                                                else                         dm_request <= dm_request_next(REQUEST_NUMBER_GET_DPC);
                                        end else begin
                                                if(dmi_wdata[`WRITE_RANGE])  dm_request <= dm_request_next(REQUEST_NUMBER_SET_CSR);
                                                else                         dm_request <= dm_request_next(REQUEST_NUMBER_GET_CSR);
                                        end
                                end
                        end else if(dmi_wdata[`CMDTYPE_RANGE]==CMDTYPE_ACCESSMEM) begin
                                specific_reg <= dmi_wdata[21:20];
                                if(dmi_wdata[`WRITE_RANGE])  dm_request <= dm_request_next(REQUEST_NUMBER_SET_MEM);
                                else                         dm_request <= dm_request_next(REQUEST_NUMBER_GET_MEM);
                        end
                end else if (bus_match_write(BUS_ADDR_DM_REQUEST)) begin
                        dm_request <= `DMREG_WIDTH'h0;
                end
        end

        reg [NUM_HART-1:0] hart_halt;
        always @(posedge clk) begin
                if(!resetn) begin
                        hart_halt <= 0;
                end else if (bus_match_write(BUS_ADDR_CORE_HALT))begin
                        hart_halt[bus_wdata] <= 1;
                end else if (bus_match_write(BUS_ADDR_CORE_RESUME))begin
                        hart_halt[bus_wdata] <= 0;
                end
        end

        reg [`DMREG_RANGE] data0;
        reg [`DMREG_RANGE] data1;
        always @(posedge clk) begin
                if(!resetn) begin
                        data0 <= `DMREG_WIDTH'h0;
                end else if(dmi_match_write(DMI_ADDR_DATA0)) begin
                        data0 <= dmi_wdata;
                end else if (bus_match_write(BUS_ADDR_DATA0))begin
                        data0 <= bus_wdata;
                end
        end
        always @(posedge clk) begin
                if(!resetn) begin
                        data1 <= `DMREG_WIDTH'h0;
                end else if(dmi_match_write(DMI_ADDR_DATA1)) begin
                        data1 <= dmi_wdata;
                end else if (bus_match_write(BUS_ADDR_DATA1))begin
                        data1 <= bus_wdata;
                end
        end


        always @(posedge clk) begin
                if(!resetn) begin
                        dmi_rdata <= 0;
                end else if (dmi_valid && ~dmi_write) begin
                        dmi_rdata <= dm_register[dmi_addr];
                end
        end

        always @(posedge clk) begin
                if(!resetn) begin
                        dmi_ready <= 0;
                end else if (dmi_match) begin
                        dmi_ready <= 0;
                end else if (dmi_valid) begin
                        dmi_ready <= 1;
                end
        end

        wire bus_match = bus_valid && bus_ready;


        always @(posedge clk) begin
                if(!resetn) begin
                        bus_rdata <= 0;
                end else if (bus_valid && !bus_write) begin
                        if({bus_addr,2'h0} < ROM_SIZE) begin
                                bus_rdata <= rom[bus_addr];
                        end else if({bus_addr,2'h0} == BUS_ADDR_DM_REQUEST) begin
                                bus_rdata <= dm_request;
                        end else if({bus_addr,2'h0} == BUS_ADDR_DATA0) begin
                                bus_rdata <= data0;
                        end else if({bus_addr,2'h0} == BUS_ADDR_DATA1) begin
                                bus_rdata <= data1;
                        end
                end
        end

        always @(posedge clk) begin
                if(!resetn) begin
                        bus_ready <= 0;
                end else if (bus_match) begin
                        bus_ready <= 0;
                end else if (bus_valid) begin
                        bus_ready <= 1;
                end
        end

        function [`DMREG_RANGE] dm_request_next;
                input [`REQUEST_NUMBER_RANGE] number;
                begin
                        dm_request_next = `DMREG_WIDTH'h0;
                        dm_request_next[`REQUEST_VALID_RANGE]  = `REQUEST_VALID_WIDTH'h1;
                        dm_request_next[`REQUEST_NUMBER_RANGE] = number;
                        dm_request_next[`HARTSEL_RANGE]        = hartsel;
                end
        endfunction

        function dmi_match_write;
                input [6:0] addr;
                begin
                        dmi_match_write = dmi_match && dmi_write && dmi_addr==addr;
                end
        endfunction

        function bus_match_write;
                input [19:0] addr;
                begin
                        bus_match_write = bus_match && bus_write && {bus_addr,2'h0}==addr;
                end
        endfunction
endmodule
