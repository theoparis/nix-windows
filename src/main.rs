use std::{path::PathBuf, process::Command};

use clap::Parser;

#[derive(Parser)]
struct Args {
	#[clap(short, long)]
	flake: String,

	#[clap(short, long)]
	root: PathBuf,
}

fn main() {
	let args = Args::parse();

	println!("Building '{}'", args.flake);

	// Run 'nix build -v <flake>.config.system.toplevel.build'
	Command::new("nix")
		.arg("-vv")
		.arg("--show-trace")
		.arg("--extra-experimental-features")
		.arg("nix-command flakes pipe-operators")
		.arg("build")
		.arg("-v")
		.arg(format!("{}.config.system.toplevel.build", args.flake))
		.stdout(std::process::Stdio::inherit())
		.stderr(std::process::Stdio::inherit())
		.status()
		.expect("failed to execute process");
}
