#[macro_use]
extern crate amplify;

use anyhow::Context;
use clap::{Parser, Subcommand};
use std::time::Instant;
use std::{fs::File, io::Read, path::PathBuf};
use warpshell::{
    cores::cms::{CardInfo, CmsOps, CmsReg},
    shells::{Shell, XilinxU55nXdmaStd},
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
enum MgmtValue {
    #[display("{0}")]
    CardInfo(CardInfo),
    #[display("{0} {1}")]
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

    // TODO: initialise it using a OnceCell and abstract it away from the board
    let shell = XilinxU55nXdmaStd::new().context("failed to connect to shell")?;
    shell.init().context("cannot initialise shell")?;

    match &cli.command {
        Some(Command::Program { file }) => {
            let mut fop = File::open(file).context("cannot open bitstream file")?;
            let mut bitstream = Vec::new();
            fop.read_to_end(&mut bitstream)
                .context("cannot read bitstream from file")?;

            println!("Programming bitstream file {}", file.display());
            let start = Instant::now();
            shell.program_user_image(&bitstream)?;
            let elapsed = start.elapsed();
            println!("Programming finished in {:?}", elapsed);
        }

        Some(Command::Get { reading }) => {
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
                MgmtValue::CardInfo(info) => println!("{info}"),
                MgmtValue::Measurement(v, u) => println!("{v} {u}"),
            }
        }

        None => {}
    }

    Ok(())
}
