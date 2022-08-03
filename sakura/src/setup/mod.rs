mod tinc;

use clap::Subcommand;
use crate::setup::tinc::install_tinc;


#[derive(Subcommand, Debug)]
pub enum SetupCommand {
    /// Install tinc 1.1
    Tinc,
}


pub fn run_setup_command(command: SetupCommand) {
    match command {
        SetupCommand::Tinc => install_tinc(),
    }
}
