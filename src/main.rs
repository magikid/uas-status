extern crate hyper;
extern crate time;
extern crate serde_json;

#[macro_use]
extern crate serde_derive;

use hyper::{Client};
use std::io::Read;
use time::Timespec;
use serde_json::*;

#[derive(Serialize,Deserialize,Debug)]
enum Color{
    Open,
    Closed
}

#[derive(Serialize,Deserialize,Debug)]
struct Attachment{
    fallback: String,
    ts: i32,
    text: String,
    color: Color
}

#[derive(Serialize,Deserialize, Debug)]
struct Message{
    username: String,
    channel: String,
    icon_url: String,
    attachments: Vec<Attachment>
}

fn main() {
    let client = Client::new();
    let uri = "https://hooks.slack.com/services/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";
    let mut response = client.post(uri)
        .body("param=hi")
        .send()
        .unwrap();
    let mut buf = String::new();
    response.read_to_string(&mut buf).unwrap();
    println!("status: {:?}", response.status_raw());
    println!("buf: {}", buf);
}
