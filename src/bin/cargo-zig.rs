use cargo_zigbuild::{Build, Run, Rustc, Test, Zig};
use clap::Parser;

#[allow(clippy::large_enum_variant)]
#[derive(Debug, Parser)]
#[clap(
    version,
    name = "cargo-zig",
    global_setting(clap::AppSettings::DeriveDisplayOrder)
)]
pub enum Opt {
    #[clap(name = "build", alias = "b")]
    Build(Build),
    #[clap(name = "rustc")]
    Rustc(Rustc),
    #[clap(name = "run", alias = "r")]
    Run(Run),
    #[clap(name = "test", alias = "t")]
    Test(Test),
    #[clap(subcommand)]
    Zig(Zig),
}

fn main() -> anyhow::Result<()> {
    let opt = Opt::parse();
    match opt {
        Opt::Build(build) => build.execute()?,
        Opt::Rustc(rustc) => rustc.execute()?,
        Opt::Run(run) => run.execute()?,
        Opt::Test(test) => test.execute()?,
        Opt::Zig(zig) => zig.execute()?,
    }
    Ok(())
}
