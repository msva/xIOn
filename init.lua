#! /usr/bin/env luajit
xIOn = require "core.xIOn"
xIOn:default_hooks();
xIOn:connect(config.mode, config.jid, config.password);
xIOn:ready_hook();
xIOn.XMPP.loop();
