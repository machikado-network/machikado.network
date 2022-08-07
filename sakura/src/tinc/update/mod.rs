use crate::aptos;
use crate::utils::run_command_and_wait;
use colored::Colorize;
use std::io::Write;
use std::thread::sleep;
use std::time::Duration;

const STORE_ADDRESS: &str = "0xc30f75fc75a381722fb493502fe292c19e3b84d7427ea13886ac642c62b3bdeb";

pub fn update_nodes(loop_sec: u64, no_restart: bool) {
    if loop_sec != 0 {
        loop {
            direct_update_nodes(no_restart);
            sleep(Duration::from_secs(loop_sec));
        }
    } else {
        // Only 1
        direct_update_nodes(no_restart);
    }
}

pub fn direct_update_nodes(no_restart: bool) {
    let store = aptos::account_resource(
        STORE_ADDRESS.to_string(),
        format!("{}::MachikadoAccount::AccountStore", STORE_ADDRESS),
    );
    let aptos::ResourceData {
        accounts,
        addresses,
    } = store.data;

    let mut is_updated = false;

    let conf = std::fs::read_to_string("/etc/tinc/mchkd/tinc.conf")
        .expect("Failed to open /etc/tinc/mchkd/tinc.conf");
    let lines = conf.split('\n').collect::<Vec<&str>>();
    let name = lines.first().expect("Failed to get name from tinc.conf");
    assert!(name.starts_with("Name = "));

    println!("    {} tinc.conf", "Resetting".bright_cyan().bold());
    let _ = std::fs::remove_file("/etc/tinc/mchkd/tinc.conf");
    let mut tincconf =
        std::fs::File::create("/etc/tinc/mchkd/tinc.conf").expect("Failed to create file");
    tincconf
        .write_all(format!("{}\nMode = switch\nDevice = /dev/net/tun\n", name).as_bytes())
        .expect("Failed to write to tinc.conf");

    for address in addresses {
        let key = aptos::machikado::AccountKey {
            owner: address.clone(),
        };
        let account: aptos::machikado::MachikadoAccount = aptos::table_items(
            accounts.handle.clone(),
            format!("{}::MachikadoAccount::AccountKey", STORE_ADDRESS),
            format!("{}::MachikadoAccount::Account", STORE_ADDRESS),
            key,
        );
        for node in account.nodes {
            println!("{} {} Node", "Setup".bright_cyan().bold(), node.name);
            let mut content = format!(
                "# {}\n# account: {}\n# address: {}\n\n",
                node.name, account.name, address
            );
            if !node.inet_hostname.vec.is_empty() {
                content += &*format!("Address = {}\n", node.inet_hostname.vec.first().unwrap());

                // Write ConnectTo = {Name}
                tincconf
                    .write_all(format!("ConnectTo = {}\n", node.name).as_bytes())
                    .expect("Failed to write tinc.conf")
            }
            if !node.inet_port.vec.is_empty() {
                content += &*format!("Port = {}\n", node.inet_port.vec.first().unwrap());
            }
            content += &*format!(
                "-----BEGIN RSA PUBLIC KEY-----\n{}\n-----END RSA PUBLIC KEY-----\n",
                node.public_key
                    .as_bytes()
                    .to_vec()
                    .chunks(64)
                    .map(String::from_utf8_lossy)
                    .collect::<Vec<_>>()
                    .join("\n")
            );
            println!(
                "{} `/etc/tinc/mchkd/hosts/{}`",
                "Checking".bright_cyan().bold(),
                node.name
            );
            let old_content = std::fs::read_to_string(format!("/etc/tinc/hosts/{}", node.name));
            if old_content.is_ok() {
                println!(
                    "{}: /etc/tinc/mchkd/hosts/{} is exists so comparing contents...",
                    "Info".bright_cyan().bold(),
                    node.name
                );
                if let Ok(c) = old_content {
                    if content == c {
                        println!(
                            "{}: Contents is same. continue...",
                            "Info".bright_cyan().bold()
                        );
                        continue;
                    }
                }
            }
            is_updated = true;
            println!(
                "{} to `/etc/tinc/mchkd/hosts/{}`",
                "Writing".bright_cyan().bold(),
                node.name
            );
            let _ = std::fs::remove_file(format!("/etc/tinc/mchkd/hosts/{}", node.name));
            let mut file = std::fs::File::create(format!("/etc/tinc/mchkd/hosts/{}", node.name))
                .expect("Failed to create file");
            file.write_all(content.as_bytes())
                .expect("Failed to write to file");
        }
    }
    println!("End writing all nodes");
    if !is_updated || !no_restart {
        return;
    }
    println!("{} tinc", "Restarting".bright_cyan().bold());
    run_command_and_wait("systemctl", &["restart", "tinc@mchkd.service"]);
}
