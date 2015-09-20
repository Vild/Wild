Wild
====
Yet another buildsystem, but in D!


JSON build file
---------------
- variables   - Contains variable that can be used everywhere else, including in
other variables and in their name.
- sources     - Array of all the source folder which Wild will scan.
- processors  - The file processers which converts one file to another.
- phonies     - Builds this every build, useful for scripts that generate code,
this will also trigger a recompilation for everything above in the hierarchy.
- missing     - Will run this target **only** if the file doesn't exist, will
only run the command once if there are multiple outputs for this. One object for
each output.
- rules       - These rules define how files are processed, via a processor.
- targets     - When you run `wild` without any arguments these files will be
compiled.

Technical notes
---------------
If the first line in any build file starts with "#!" (aka a shebang), it will
ignore the whole line. This allows the build file to be a executable script file
on \*nix systems

Object file will have the same timestamp as the source file. If they differ, it
will recompile that file and everything above it in the hierarchy.
