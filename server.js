// nicsblog server in node
// Copyright (C) 2018 by Nic Ferrier

const fs = require(__dirname + "/fsasync.js");
const path = require('path');
const { URL } = require('url');
const crypto = require("crypto");
const { spawn } = require("child_process");
const { Transform } = require("stream");

const express = require("express");
const bodyParser = require("body-parser");
const multer = require("multer");
const indexer = require("serve-index");
const SSE = require("sse-node");
const http = require("http");
const proxy = require('express-http-proxy');
const cookieParser = require('cookie-parser');
 
const app = express();

const Creole = require('npm-creole');
const creole = new Creole(/*options*/);

async function wiki2html (page) {
    let header = await fs.readFileAsync("template/headerhtml");
    let footer = await fs.readFileAsync("template/footerhtml");
    let file = await fs.readFileAsync(page);
    let htmlStart = `<html>
        <head>
          <link rel="stylesheet" href="/stuff/css/site.css" type="text/css"/>
          <link rel="icon" href="/stuff/ico/favicon.ico" type="image/x-icon"/>
        </head>
        <body>`;
    let parsed = creole.parse(file);
    return htmlStart + header +  parsed + footer + "</body></html>";
}

exports.boot = function (portToListen, options) {
    let opts = options != undefined ? options : {};
    let rootDir = opts.rootDir != undefined ? opts.rootDir : __dirname + "/stuff";

    app.use(cookieParser());
    app.use(bodyParser.json());
    app.use(bodyParser.urlencoded({extended: true}));
    app.use("/stuff/", express.static(rootDir));

    app.get("/", async function (req, res) {
        let blogPath = __dirname + "/blog";
        let blogDir = await fs.readdirAsync(blogPath);
        let dated = blogDir.filter(name => /[0-9_]+/.exec(name));
        dated.sort();
        let newestDir = dated.reverse()[0];
        let newestPath = blogPath + "/" + newestDir;
        let dateDir = await fs.readdirAsync(newestPath);
        let articlePath = newestPath + "/" + dateDir[0];
        let page = await wiki2html(articlePath);
        res.set("Content-type", "text/html");
        res.send(page);
    });

    app.get("/blog/:date([0-9]+_[0-9]+)/:article([A-Za-z0-9_-]+)",
            async function (req, res) {
                let { date, article } = req.params;
                let path = date + "/" + article + ".creole";
                let articlePath = __dirname + "/blog/" + path;
                let exists = await fs.existsAsync(articlePath);
                if (!exists) {
                    res.sendStatus(404);
                    return
                }
                let page = await wiki2html(articlePath);
                res.set("Content-type", "text/html");
                res.send(page);
            });
    
    app.listen(portToListen, "localhost", function () {
        console.log("listening on " + portToListen);
    });
};

exports.boot(8082);

// server.js ends here
