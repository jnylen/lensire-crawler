# Lensire Crawler

## Introduction

> Parses HTML etc from different contact lens webstores and returns them in a parse-able JSON format used by Lensire.com.

## Supported Websites

Currently we have these websites listed below as being supported:

* 1a-sehen
* 123optic
* Lensexpress

## Installation

You need Rust and Elixir installed. Rust is required by Meeseeks.

1. Pull it down
2. Run `mix deps.get`
3. Run `iex -S mix`
4. Run `Crawler.Website.execute("123optic")`
5. Open the `websites` folder.