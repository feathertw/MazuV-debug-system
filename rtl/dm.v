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

        `include "debug/rtl/dm_header.v"

        integer i;
        localparam ROM_SIZE = 'h200;


        reg  [ 7:0] rom_file [0:ROM_SIZE-1];
        wire [31:0] rom      [0:ROM_SIZE/4-1];
        initial begin
                $readmemh("debug/src/dm_rom.hex", rom_file);
        end
        genvar gi;
        generate
                for (gi = 0; gi < ROM_SIZE; gi = gi + 4) begin
                        assign rom[gi/4] = {rom_file[gi+3],rom_file[gi+2],rom_file[gi+1],rom_file[gi+0]};
                end
        endgenerate

        wire dmi_match = dmi_valid && dmi_ready;
        assign interrupt = dmcontrol_haltreq ;

        reg [31:0] dmi_register [0:2**7-1];
        always @* begin
                for (i=0; i<2**7; i=i+1) begin
                        dmi_register[i] = 32'h0;
                end
                dmi_register[DMI_ADDR_DMCONTROL][`DMCONTROL_HALTREQ_RANGE]  = dmcontrol_haltreq;
                dmi_register[DMI_ADDR_DMCONTROL][`DMCONTROL_DMACTIVE_RANGE] = dmcontrol_dmactive;
                dmi_register[DMI_ADDR_DMSTATUS][`DMSTATUS_ALLRUNNING_RANGE] = ~hart_halt[hartsel];
                dmi_register[DMI_ADDR_DMSTATUS][`DMSTATUS_ANYRUNNING_RANGE] = ~hart_halt[hartsel];
                dmi_register[DMI_ADDR_DMSTATUS][`DMSTATUS_ALLHALTED_RANGE]  =  hart_halt[hartsel];
                dmi_register[DMI_ADDR_DMSTATUS][`DMSTATUS_ANYHALTED_RANGE]  =  hart_halt[hartsel];
        end

        reg [`HARTSEL_RANGE] hartsel;

        reg [`DMCONTROL_HALTREQ_RANGE]  dmcontrol_haltreq;
        reg [`DMCONTROL_DMACTIVE_RANGE] dmcontrol_dmactive;
        always @(posedge clk) begin if(!resetn) begin
                        dmcontrol_dmactive <= `DMCONTROL_DMACTIVE_WIDTH'h0;
                end else if(dmi_match_write(DMI_ADDR_DMCONTROL)) begin
                        dmcontrol_dmactive <= dmi_wdata[`DMCONTROL_DMACTIVE_RANGE];
                end
        end
        always @(posedge clk) begin
                if(!resetn || !dmcontrol_dmactive) begin
                        dmcontrol_haltreq <= `DMCONTROL_HALTREQ_WIDTH'h0;
                end else if(dmi_match_write(DMI_ADDR_DMCONTROL)) begin
                        dmcontrol_haltreq <= dmi_wdata[`DMCONTROL_HALTREQ_RANGE];
                end
        end
        always @(posedge clk) begin
                if(!resetn || !dmcontrol_dmactive) begin
                        hartsel <= `HARTSEL_WIDTH'h0;
                end else if(dmi_match_write(DMI_ADDR_DMCONTROL)) begin
                        hartsel <= {dmi_wdata[`DMCONTROL_HARTSELHI_RANGE],dmi_wdata[`DMCONTROL_HARTSELLO_RANGE]};
                end
        end

        // dm_request: [31]==valid, [30:20]==request, [19:0]==hartid
        // request==0 resume
        // request==1 set_s0
        // request==2 set_s1
        // request==3 set_other_gpr
        // request==4 get_s0
        // request==5 get_s1
        // request==6 get_other_gpr
        // request==7 set_csr
        // request==8 get_csr
        reg [31:0] dm_request;
        always @(posedge clk) begin
                if(!resetn) begin
                        dm_request <= 0;
                end else if(dmi_match_write(DMI_ADDR_DMCONTROL) && dmi_wdata[`DMCONTROL_RESUMEREQ_RANGE]) begin
                        dm_request <= 32'h8000_0000;
                end else if (bus_match_write(BUS_ADDR_DM_REQUEST))begin
                        dm_request <= 0;
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

        always @(posedge clk) begin
                if(!resetn) begin
                        dmi_rdata <= 0;
                end else if (dmi_valid && ~dmi_write) begin
                        dmi_rdata <= dmi_register[dmi_addr];
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
                        if({bus_addr,2'h0}<'h200) begin
                                bus_rdata <= rom[bus_addr];
                        end else if({bus_addr,2'h0} == BUS_ADDR_DM_REQUEST) begin
                                bus_rdata <= dm_request;
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
