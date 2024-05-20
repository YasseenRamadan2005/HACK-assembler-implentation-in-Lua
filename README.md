# HACK-assembler-implentation-in-Lua
This is the implementation of an assembler for the HACK machine language for project 6 of nand2tetris. The assembler uses two arguments, the first is the folder name that contains the assembly, the second is the .asm file. The assembler creates the .hack file in the folder. Run it as :  lua assembler.lua &lt;folder_name> &lt;file.asm> 

This is my first non-trivial coding project, so any helpful advice is appreciated. Pong.asm takes ~4.5 seconds to assemble, and I'm interested in shaving down that time as much as I can in lua.

PS:
  The Lua program needs the LuaFileSystem library. You can install it by doing - luarocks install luafilesystem


Edit: Got it to less than a second for Pong :)

Edit2: Now .048 seconds. Use sudo luarocks install bitlib to install the bitshifting library
