# lualibvoikko
Lualibvoikko is Lua (version 5.3) bindings for Libvoikko (voikko.puimula.org).

Folder C has the interface.

Folder lua5.3 has package Voikko.lua and a file of examples.
You can run the examples like this

lua5.3 examples.lua


You should define environment variables LUA_PATH and LUA_CPATH so that
lua finds Voikko.lua and lualibvoikko.so, for example (in file .bashrc)

export LUA_PATH="/usr/local/lib/lua5.3/?.lua;;"
export LUA_CPATH="/usr/local/lib/?.so;;"


Copyright (©) 2020, 2021 Hannu Väisänen

Lualibvoikko is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at your
option) any later version.
