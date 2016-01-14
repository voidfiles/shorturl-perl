#! /usr/bin/env bash
cd shorturl;
starman $@ -R app.psgi;
