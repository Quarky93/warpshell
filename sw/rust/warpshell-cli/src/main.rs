#[macro_use]
extern crate amplify_derive;

use anyhow::Context;
use clap::{Parser, Subcommand};
use log::warn;
use std::path::PathBuf;
use warpshell::{
    cores::cms::{CardInfo, CmsOps, CmsReg},
    shells::XilinxU55nXdmaStd,
};

/// Interface to Warpshell on an FPGA
#[derive(Parser)]
#[command(author, version, about)]
struct Cli {
    /// Config file location
    #[arg(short, long)]
    config: Option<PathBuf>,
    /// CLI command
    #[command(subcommand)]
    command: Option<Command>,
}

#[derive(Subcommand)]
enum Command {
    /// Program the bitstream onto the FPGA
    Program {
        /// Warpshell bitstream file location
        #[arg(short, long)]
        file: PathBuf,
    },

    /// Read management register values
    Get {
        #[command(subcommand)]
        reading: MgmtReading,
    },
}

#[derive(Debug, Copy, Clone, PartialEq, Eq, PartialOrd, Ord, Display, Subcommand)]
#[display(doc_comments)]
enum MgmtReading {
    /// Card info
    CardInfo,
    /// FPGA temperature
    FpgaTemp,
    /// HBM temperature
    HbmTemp,
    /// Board power
    BoardPower,
}
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Display)]
#[display(doc_comments)]
enum MgmtValue {
    /// Card info
    CardInfo(CardInfo),
    /// Measurement
    Measurement(u32, MeasurementUnit),
}

#[derive(Debug, Copy, Clone, PartialEq, Eq, PartialOrd, Ord, Display)]
#[display(doc_comments)]
enum MeasurementUnit {
    /// C
    C,
    /// mW
    MilliW,
}

fn main() -> anyhow::Result<()> {
    env_logger::init();
    let cli = Cli::parse();

    if let Some(config) = cli.config.as_deref() {
        println!("Config file: {}", config.display());
    }

    match &cli.command {
        Some(Command::Program { file }) => {
            println!("Programming bitstream file {}", file.display());

            warn!("program subcommand is not implemented yet");
        }

        Some(Command::Get { reading }) => {
            // TODO: initialise it using a OnceCell and abstract it away from the board
            let shell = XilinxU55nXdmaStd::new().context("failed to initialise shell")?;
            let value = match reading {
                MgmtReading::CardInfo => MgmtValue::CardInfo(shell.cms.get_card_info()?),
                MgmtReading::FpgaTemp => MgmtValue::Measurement(
                    shell.cms.get_cms_reg(CmsReg::FpgaTempInst)?,
                    MeasurementUnit::C,
                ),
                MgmtReading::HbmTemp => MgmtValue::Measurement(
                    shell.cms.get_cms_reg(CmsReg::Hbm0TempInst)?,
                    MeasurementUnit::C,
                ),
                MgmtReading::BoardPower => {
                    let voltage = shell.cms.get_cms_reg(CmsReg::Pex12VInst)?;
                    let current = shell.cms.get_cms_reg(CmsReg::Pex12VCurrentInInst)?;
                    let voltage_aux = shell.cms.get_cms_reg(CmsReg::Aux12VInst)?;
                    let current_aux = shell.cms.get_cms_reg(CmsReg::Aux12VCurrentInInst)?;
                    // TODO: this is only a proof-of-concept formula, needs correcting
                    MgmtValue::Measurement(
                        voltage * current / 1000 + voltage_aux * current_aux / 1000,
                        MeasurementUnit::MilliW,
                    )
                }
            };

            match value {
                // TODO: add a Display instance for CardInfo
                MgmtValue::CardInfo(info) => println!("{info:?}"),
                MgmtValue::Measurement(v, u) => println!("{v} {u}"),
            }
        }

        None => {}
    }

    Ok(())
}
