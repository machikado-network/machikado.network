mod setup;

use clap::Subcommand;
use setup::{setup_tinc, validate_ip_addr, validate_name};
use std::net::Ipv4Addr;

#[derive(Subcommand, Debug)]
pub enum TincCommand {
    /// Setup Tinc Node
    Setup {
        /// Tinc node name what you want. e.g. syamimomo
        #[clap(value_parser = validate_name)]
        name: String,
        #[clap(value_parser = validate_ip_addr)]
        ip_addr: Ipv4Addr,
    },
}

pub fn run_tinc_command(command: TincCommand) {
    match command {
        TincCommand::Setup { name, ip_addr } => setup_tinc(name, ip_addr),
    }
}
