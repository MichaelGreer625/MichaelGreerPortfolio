module pc_ocntrol_test();

reg [2:0] C;
reg [8:0] I;
reg [2:0] F;
reg Branch;
reg BranchReg;
reg [15:0] PC_in;
reg [15:0] rs_in;

wire [15:0] PC_out;

PC_control iDUT(.C(C), .I(I), .F(F), .Branch(Branch), .BranchReg(BranchReg), .PC_in(PC_in), .rs_in(rs_in), .PC_out(PC_out));


// just manually edit value and watch what happens
initial begin
forever begin
    #5;
    C = 3'b1001;
    I = 9'h02;
    F = 3'b100;
    Branch = 1'b1;
    BranchReg = 1'b0;
    rs_in = 16'h00ff;
    #5;
    if (PC_out != PC_in + 2) begin
        $display("branch taken");
    end
    PC_in = PC_out;
end
end

initial begin
PC_in = 16'h0000;
#1000;
$stop;
end

endmodule
