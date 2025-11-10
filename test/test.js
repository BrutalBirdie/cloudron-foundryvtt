#!/usr/bin/env node

/* jslint node:true */
/* global it, xit, describe, before, after, afterEach */

'use strict';

require('chromedriver');

const execSync = require('child_process').execSync,
    fs = require('fs'),
    expect = require('expect.js'),
    path = require('path'),
    { Builder, By, Key, until } = require('selenium-webdriver'),
    { Options } = require('selenium-webdriver/chrome');

const username = process.env.TEST_USERNAME || process.env.USERNAME;
const password = process.env.TEST_PASSWORD || process.env.PASSWORD;
const SNAP = process.env.SNAP || false;

if (!username || !password) {
    console.log('USERNAME and PASSWORD env vars need to be set');
    process.exit(1);
}

describe('Application life cycle test', function () {
    this.timeout(0);

    let browser, app;

    const LOCATION = process.env.LOCATION || 'test';
    const EXEC_ARGS = { cwd: path.resolve(__dirname, '..'), stdio: 'inherit' };
    const TIMEOUT = parseInt(process.env.TIMEOUT, 10) || 50000;

    before(function () {
        const chromeOptions = new Options().windowSize({ width: 1280, height: 1024 });
        if (process.env.CI) chromeOptions.addArguments('no-sandbox', 'disable-dev-shm-usage', 'headless');
        if (process.env.SNAP) chromeOptions.addArguments('--no-sandbox', '--disable-dev-shm-usage', '--remote-debugging-port=9222');
        browser = new Builder().forBrowser('chrome').setChromeOptions(chromeOptions).build();
        if (!fs.existsSync('./screenshots')) fs.mkdirSync('./screenshots');
    });

    after(async function () {
        browser.quit();
    });

    afterEach(async function () {
        if (!process.env.CI || !app) return;

        const currentUrl = await browser.getCurrentUrl();
        if (!currentUrl.includes(app.domain)) return;
        expect(this.currentTest.title).to.be.a('string');

        const screenshotData = await browser.takeScreenshot();
        fs.writeFileSync(`./screenshots/${new Date().getTime()}-${this.currentTest.title.replaceAll(' ', '_')}.png`, screenshotData, 'base64');
    });

    async function waitForElement(elem) {
        await browser.wait(until.elementLocated(elem), TIMEOUT);
        await browser.wait(until.elementIsVisible(browser.findElement(elem)), TIMEOUT);
    }

    async function getAppInfo() {
        const inspect = JSON.parse(execSync('cloudron inspect'));
        app = inspect.apps.filter(a => a.location === LOCATION || a.location === LOCATION + '2')[0];
        expect(app).to.be.an('object');
    }

    async function couldSubmitKey() {
        await browser.get(`https://${app.fqdn}`);
        await waitForElement(By.xpath(`//button/label[contains(text(), "Submit Key")]`));
        await browser.findElement(By.xpath(`//button/label[contains(text(), "Submit Key")]`));
    }

    xit('build app', () => { execSync('cloudron build', EXEC_ARGS); });

    it('install app', () => { execSync(`cloudron install --location ${LOCATION}`, EXEC_ARGS); });

    it('can get app information', getAppInfo);
    it('Can see submit key button', couldSubmitKey);

    it('can restart app', () => { execSync(`cloudron restart --app ${app.id}`, EXEC_ARGS); });
    it('Can see submit key button', couldSubmitKey);

    it('backup app', function () { execSync(`cloudron backup create --app ${app.id}`, EXEC_ARGS); });
    it('restore app', () => {
        const backups = JSON.parse(execSync('cloudron backup list --raw'));
        execSync('cloudron uninstall --app ' + app.id, EXEC_ARGS);
        execSync('cloudron install --location ' + LOCATION + '', EXEC_ARGS);
        const inspect = JSON.parse(execSync('cloudron inspect'));
        app = inspect.apps.filter(a => a.location === LOCATION)[0];
        execSync(`cloudron restore --backup ${backups[0].id} --app ${app.id}`, EXEC_ARGS);
    });
    it('Can see submit key button', couldSubmitKey);

    it('move to different location', () => { execSync(`cloudron configure --location ${LOCATION}2 --app ${app.id}`, EXEC_ARGS); });
    it('can get app information', getAppInfo);
    it('Can see submit key button', couldSubmitKey);

    it('uninstall app', () => { execSync(`cloudron uninstall --app ${app.id}`, EXEC_ARGS); });

    // test update
    it('can install app for update', () => { execSync(`cloudron install --appstore-id com.transmissionbt.cloudronapp --location ${LOCATION}`, EXEC_ARGS); });
    it('can get app information', getAppInfo);
    it('can update', () => { execSync(`cloudron update --app ${app.id}`, EXEC_ARGS); });
    it('uninstall app', () => { execSync(`cloudron uninstall --app ${app.id}`, EXEC_ARGS); });
});
