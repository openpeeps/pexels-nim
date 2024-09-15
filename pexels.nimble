# Package

version       = "0.1.0"
author        = "George Lemon"
description   = "Nim library for the Pexels API"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 2.0.2"
requires "jsony"

import std/[os, macros]
proc targetSource(x: string): string {.compileTime.} =
  result = x & " src" / "pexels" / x & ".nim" 

macro genTaskBuilders*(modules: static seq[string]) =
  result = newStmtList()
  for k in modules:
    add result,
      nnkCommand.newTree(
        ident"task",
        ident("build_" & k),
        newLit("build /" & k),
        nnkStmtList.newTree(
          nnkCommand.newTree(
            ident"exec",
            nnkInfix.newTree(
              ident"&",
              newLit"nim c -d:ssl -o:./bin/",
              newCall(
                ident"targetSource",
                newLit(k)
              )
            )
          )
        )
      )

genTaskBuilders(@["photo", "video"])