use colored::*;
use std::net::Ipv4Addr;
use std::str::FromStr;

pub fn validate_name(s: &str) -> Result<String, String> {
    if s.len() > 32 {
        return Err("Names must be 32 characters or less.".to_string());
    }
    if s.len() == 0 {
        return Err("Names must be 1 characters or more".to_string());
    }
    for char in s.chars() {
        if char.is_digit(10) {
            continue;
        }
        match char {
            'a'..='z' => continue,
            '0'..='9' => continue,
            _ => return Err("You can use [0-9a-z] to name.".to_string()),
        }
    }
    Ok(s.to_string())
}

pub fn validate_ip_addr(s: &str) -> Result<Ipv4Addr, String> {
    let r = Ipv4Addr::from_str(s);
    if r.is_err() {
        return Err("Invalid IP address syntax".to_string());
    }
    let addr = r.unwrap();

    match addr.octets() {
        [a, b, _, _] if a != 10 || b != 50 => Err("IP address must be in 10.50.0.0/16".to_string()),
        [_, _, c, d] if c == 0 || d == 0 => Err("Subnet ID must be from 1 to 255.".to_string()),
        _ => Ok(addr),
    }
}

pub fn setup_tinc(name: String, ip_addr: Ipv4Addr) {}

pub fn install_tinc() {
    println!("{}", "Install tinc 1.0".bright_green())
}

#[cfg(test)]
mod tests {
    use super::{validate_ip_addr, validate_name};

    #[test]
    fn test_validate_name() {
        assert!(validate_name("sumidora").is_ok());
        assert!(validate_name("").is_err());
        assert!(validate_name("sumidora123").is_ok());
        assert!(validate_name("Sumidora").is_err());
        assert!(validate_name("sumidorasumidorasumidorasumidoraextra").is_err());
    }

    #[test]
    fn test_validate_ip_addr() {
        assert!(validate_ip_addr("10.50.1.1").is_ok());
        assert!(validate_ip_addr("11.50.0.1").is_err());
        assert!(validate_ip_addr("10.50.0.1").is_err());
        assert!(validate_ip_addr("10.50.1.0").is_err());
    }
}
