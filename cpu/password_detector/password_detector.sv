module password_detector(
    input logic [3:0] new_password,
    input logic serial_in,
    input logic en_renter, // used to renter the password from finished/error to starte

    input logic clk,
    input logic reset,

    output logic password_success,
    output logic password_error,

    // debugging
    output logic [2:0] state_out,
    output logic [2:0] progress,
    output logic [3:0] pass
);
    // FSM Design
    // idle -> configure password -> enter password -> password result
    // password result case
    // if success: success flag and goes to enter password with renter input active
    // if failure: error flag and goes to enter password with renter input active
    // password is configured once at the start.

    typedef enum logic [2:0] { 
        IDLE,
        CONFIGURE_PASSWORD,
        ENTER_PASSWORD,
        ERROR,
        SUCCESS
    } state_t;

    state_t state;
    logic [1:0] password_progress;
    logic [3:0] password;

    always_ff @(posedge clk) begin
        if (reset) begin 
            state <= IDLE;
            password <= 0;
            password_progress <= 0;
        end
        else begin
            case (state)
                IDLE: begin 
                    state <= CONFIGURE_PASSWORD;
                end

                CONFIGURE_PASSWORD: begin
                    password <= new_password;
                    state <= ENTER_PASSWORD;
                end

                ENTER_PASSWORD: begin
                    if (password[password_progress] == serial_in) begin
                        if (password_progress == 3) begin
                            state <= SUCCESS;
                        end
                        else begin
                            password_progress <= password_progress + 1;
                        end
                    end
                    else begin
                        state <= ERROR;
                    end
                end

                ERROR: begin
                    if (en_renter) begin
                        state <= ENTER_PASSWORD;
                        password_progress <= 0;
                    end
                    else begin
                        state <= ERROR;
                    end
                end

                SUCCESS: begin
                    if (en_renter) begin
                        state <= ENTER_PASSWORD;
                        password_progress <= 0;
                    end
                    else begin
                        state <= SUCCESS;
                    end
                end

            endcase

        end
    end

    // OUTPUT FLAGS
    assign password_success = state == SUCCESS ? 1 : 0;
    assign password_error = state == ERROR ? 1 : 0;
    assign state_out = state;
    assign progress = password_progress;
    assign pass = password;

endmodule