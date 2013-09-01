---
layout: default
title: Home
---

Starfall is an object-oriented scripting framework for Garry's Mod. It allows for addons to be scriptable serverside or clientside by exposing a limited set of functions and monitors how many instructions it executes. It initially was intended to replace Wiremod's aging Expression 2 Processor with something faster and better.

Features of Starfall
--------------------
* _It's Lua_. The only parser and compiler is Lua's own loadstring. Starfall runs native Lua code in a restricted environment. Not only does this mean execution is fast, but all of Lua's features are directly available for use.
* _It's extendable_. SF is a framework; it is not inherently bound to one application. SF is a good choice for allowing players to program parts of your mod.
* _It's safe_. Multiple security measures are in place so that the running code does not break out of its sandbox.
* _It's documented_. SF contains in-code documentation parseable by an included custom LuaDoc parser.

At the moment, Starfall requires Wiremod to be installed. The interaction however is minimal, and there are plans to sever this dependancy.
