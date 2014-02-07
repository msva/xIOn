#! /usr/bin/env luajit
math.randomseed(os.time());
xIOn = require "core.xIOn"
xIOn:default_hooks();
xIOn:connect(config.xmpp.mode, config.xmpp.jid, config.xmpp.password);
xIOn:ready_hook();
xIOn.XMPP.loop();
