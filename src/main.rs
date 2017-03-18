extern crate hyper;

use hyper::{Client};

fn main() {
    let client = Client::new();
    let url = "http://httpbin.org/status/201";
    let mut response = match client.get(url).send() {
        Ok(response) => response,
        Err(_) => panic!("Problem requesting"),
    };
    let mut buf = String::new();
    match response.read_to_string(&mut buf){
        Ok(_) => (),
        Err(_) => panic!("I give up"),
    };
    println!("buf: {}", buf);
}
