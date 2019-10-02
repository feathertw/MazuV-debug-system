module dm #(
	parameter NUM_HART = 1
) (
        output            interrupt,
        input             dmi_valid,
        output reg        dmi_ready,
        input             dmi_write,
        input [ 8:2]      dmi_addr,
        input [31:0]      dmi_wdata,
        output reg [31:0] dmi_rdata,

	input             bus_valid,
	output reg        bus_ready,
	input             bus_write,
	input   [19:0]    bus_addr,
	input   [31:0]    bus_wdata,
	output reg [31:0] bus_rdata,

	input resetn,
	input clk
);
        localparam ROM_SIZE = 'h200;

        `include "debug/rtl/header.v"

        integer i;

        assign interrupt = haltreq;
        wire [`BUSY_RANGE] busy = |dm_request[`REQUEST_NUMBER_RANGE];

        wire dmi_match = dmi_valid && dmi_ready;
        wire bus_match = bus_valid && bus_ready;
        always @(posedge clk) begin
                if(!resetn) begin
                        dmi_ready <= 0;
                end else if (dmi_match) begin
                        dmi_ready <= 0;
                end else if (dmi_valid) begin
                        dmi_ready <= 1;
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

        // For bus address read data
        wire [`DMREG_RANGE] dm_rom_rdata;
        reg  [11:0] instr_fix;
        reg  [11:0] instr_fix_reg;
        dm_rom #(
                .ROM_SIZE(ROM_SIZE)
        ) dm_rom (
                .instr_fix(instr_fix),
                .addr(bus_addr[9:0]),
                .rdata(dm_rom_rdata)

        );
        always @(posedge clk) begin
                if(!resetn) begin
                        bus_rdata <= 0;
                end else if (bus_valid && !bus_write) begin
                        if(bus_addr < ROM_SIZE) begin
                                bus_rdata <= dm_rom_rdata;
                        end else begin
                                case(bus_addr)
                                BUS_ADDR_DM_REQUEST: bus_rdata <= dm_request;
                                BUS_ADDR_DATA0:      bus_rdata <= data0;
                                BUS_ADDR_DATA1:      bus_rdata <= data1;
                                endcase
                        end
                end
        end


        // For DMI address read data
        reg [`DMREG_RANGE] dm_register [0:2**7-1];
        always @* begin
                for (i=0; i<2**7; i=i+1) begin
                        dm_register[i] = 32'h0;
                end
                dm_register[DMI_ADDR_DATA0] = data0;
                dm_register[DMI_ADDR_DATA1] = data1;
                dm_register[DMI_ADDR_DMCONTROL][`HALTREQ_RANGE]   =  haltreq;
                dm_register[DMI_ADDR_DMCONTROL][`DMACTIVE_RANGE]  =  dmactive;
                dm_register[DMI_ADDR_DMSTATUS][`ALLRUNNING_RANGE] = ~hart_halt[hartsel];
                dm_register[DMI_ADDR_DMSTATUS][`ANYRUNNING_RANGE] = ~hart_halt[hartsel];
                dm_register[DMI_ADDR_DMSTATUS][`ALLHALTED_RANGE]  =  hart_halt[hartsel];
                dm_register[DMI_ADDR_DMSTATUS][`ANYHALTED_RANGE]  =  hart_halt[hartsel];
                dm_register[DMI_ADDR_ABSTRACTCS][`BUSY_RANGE]     =  busy;
                dm_register[DMI_ADDR_ABSTRACTCS][`CMDERR_RANGE]   =  cmderr;
        end
        always @(posedge clk) begin
                if(!resetn) begin
                        dmi_rdata <= 0;
                end else if (dmi_valid && ~dmi_write) begin
                        dmi_rdata <= dm_register[dmi_addr];
                end
        end




        // For dm register
        reg [`HARTSEL_RANGE]  hartsel;
        reg [`HALTREQ_RANGE]  haltreq;
        reg [`DMACTIVE_RANGE] dmactive;
        reg [`CMDERR_RANGE]   cmderr;
        reg [`DMREG_RANGE] data0;
        reg [`DMREG_RANGE] data1;

        always @(posedge clk) begin
                if(!resetn) begin
                        cmderr <= CMDERR_NONE;
                end else if(dmi_match_write(DMI_ADDR_COMMAND) && dmi_wdata[`CMDTYPE_RANGE]==CMDTYPE_ACCESSREG && dmi_wdata[`AARSIZE_RANGE]!=AARSIZE_32BITS) begin
                        cmderr <= CMDERR_EXCEPTION;
                end else if(dmi_match_write(DMI_ADDR_ABSTRACTCS) && (&dmi_wdata[`CMDERR_RANGE])) begin
                        cmderr <= CMDERR_NONE;
                end
        end
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

        // For dm internal using register
        reg [NUM_HART-1:0] hart_halt;
        reg [`DMREG_RANGE] dm_request;

        always @(posedge clk) begin
                if(!resetn) begin
                        hart_halt <= 0;
                end else if (bus_match_write(BUS_ADDR_CORE_HALT))begin
                        hart_halt[bus_wdata] <= 1;
                end else if (bus_match_write(BUS_ADDR_CORE_RESUME))begin
                        hart_halt[bus_wdata] <= 0;
                end
        end

        reg [`DMREG_RANGE] dm_request_reg;
        reg [`DMREG_RANGE] dm_request_gpr;
        reg [`DMREG_RANGE] dm_request_csr;
        reg [`DMREG_RANGE] dm_request_mem;
        always @* begin
                if(dmi_wdata[`REGNO_RANGE]==REGNO_GPR_BASE+GPR_S0) begin
                        if(dmi_wdata[`WRITE_RANGE])  dm_request_gpr = dm_request_next(REQUEST_NUMBER_SET_S0);
                        else                         dm_request_gpr = dm_request_next(REQUEST_NUMBER_GET_S0);
                end else if(dmi_wdata[`REGNO_RANGE]==REGNO_GPR_BASE+GPR_S1) begin
                        if(dmi_wdata[`WRITE_RANGE])  dm_request_gpr = dm_request_next(REQUEST_NUMBER_SET_S1);
                        else                         dm_request_gpr = dm_request_next(REQUEST_NUMBER_GET_S1);
                end else begin
                        if(dmi_wdata[`WRITE_RANGE])  dm_request_gpr = dm_request_next(REQUEST_NUMBER_SET_GPR);
                        else                         dm_request_gpr = dm_request_next(REQUEST_NUMBER_GET_GPR);
                end
        end
        always @* begin
                if(dmi_wdata[`REGNO_RANGE]==REGNO_CSR_BASE+CSR_DPC) begin
                        if(dmi_wdata[`WRITE_RANGE])  dm_request_csr = dm_request_next(REQUEST_NUMBER_SET_DPC);
                        else                         dm_request_csr = dm_request_next(REQUEST_NUMBER_GET_DPC);
                end else begin
                        if(dmi_wdata[`WRITE_RANGE])  dm_request_csr = dm_request_next(REQUEST_NUMBER_SET_CSR);
                        else                         dm_request_csr = dm_request_next(REQUEST_NUMBER_GET_CSR);
                end
        end
        always @* begin
                if(dmi_wdata[`WRITE_RANGE])  dm_request_mem = dm_request_next(REQUEST_NUMBER_SET_MEM);
                else                         dm_request_mem = dm_request_next(REQUEST_NUMBER_GET_MEM);
        end
        always @* begin
                instr_fix_reg   = 'b0;
                dm_request_reg  = `DMREG_WIDTH'h0;
                if(dmi_wdata[`TRANSFER_RANGE] && dmi_wdata[`AARSIZE_RANGE]==AARSIZE_32BITS) begin
                        if(REGNO_FPR_BASE <= dmi_wdata[`REGNO_RANGE]) begin

                        end else if(REGNO_GPR_BASE <= dmi_wdata[`REGNO_RANGE]) begin
                                instr_fix_reg  = dmi_wdata[4:0];
                                dm_request_reg = dm_request_gpr;
                        end else begin
                                instr_fix_reg  = dmi_wdata[11:0];
                                dm_request_reg = dm_request_csr;
                        end
                end
        end
        always @(posedge clk) begin
                if(!resetn) begin
                        dm_request <= 0;
                        instr_fix  <= 0;
                end else if(dmi_match_write(DMI_ADDR_DMCONTROL) && dmi_wdata[`RESUMEREQ_RANGE]) begin
                        dm_request <= dm_request_next(REQUEST_NUMBER_RESUME);
                end else if(dmi_match_write(DMI_ADDR_COMMAND) && (cmderr==CMDERR_NONE)) begin
                        case(dmi_wdata[`CMDTYPE_RANGE])
                                CMDTYPE_ACCESSREG: begin
                                        instr_fix  <= instr_fix_reg;
                                        dm_request <= dm_request_reg;
                                end
                                CMDTYPE_QUICKACCESS:begin
                                end
                                CMDTYPE_ACCESSMEM:begin
                                        instr_fix  <= dmi_wdata[21:20];
                                        dm_request <= dm_request_mem;
                                end
                        endcase
                end else if (bus_match_write(BUS_ADDR_DM_REQUEST)) begin
                        dm_request <= `DMREG_WIDTH'h0;
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
                input [8:2] addr;
                begin
                        dmi_match_write = dmi_match && dmi_write && dmi_addr==addr;
                end
        endfunction
        function bus_match_write;
                input [19:0] addr;
                begin
                        bus_match_write = bus_match && bus_write && bus_addr==addr;
                end
        endfunction
endmodule
