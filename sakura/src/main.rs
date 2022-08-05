mod setup;

use crate::setup::{run_setup_command, SetupCommand};
use clap::{Parser, Subcommand};

#[derive(Subcommand, Debug)]
enum SubCommand {
    Setup {
        #[clap(subcommand)]
        subcommand: SetupCommand,
    },
}

/// Simple program to greet a person
#[derive(Parser, Debug)]
#[clap(author, version, about, long_about = None)]
struct Args {
    #[clap(subcommand)]
    subcommand: SubCommand,
}

fn main() {
    let args = Args::parse();
    match args.subcommand {
        SubCommand::Setup { subcommand } => {
            run_setup_command(subcommand);
        }
    }
}
