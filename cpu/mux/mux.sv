module mux_2_to_1(
    input logic a,
    input logic b,
    input logic sel,
    output logic y
);

    assign y = sel ? b : a;
endmodule