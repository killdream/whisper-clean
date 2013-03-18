## Module whisper-clean
#
# Removes build artifacts and backup files from a project.
#
# 
# Copyright (c) 2013 Quildreen "Sorella" Motta <quildreen@gmail.com>
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module.exports = (whisper) ->

  fs         = require 'fs'
  path       = require 'path'
  glob       = (require 'glob').sync
  remove-dir = (require 'wrench').rmdir-sync-recursive

  { concat-map, unique } = require 'prelude-ls'


  ### λ expand
  # Returns a list of files that match a list of glob patterns.
  #
  # :: [String] -> [String]
  expand = unique . (concat-map glob)


  ### λ path-components
  # Returns a list of path components.
  #
  # :: String -> [String]
  path-components = (x) -> (path.resolve x).split path.sep


  ### λ descendant-of
  # Checks if a given file descends of the given path.
  #
  # :: String -> String -> Bool
  descendant-of = (file, dir) -->
    dir-parts  = path-components dir
    file-parts = path-components file
    dir-parts.every (x, i) -> x is file-parts[i]

  
  ### λ descendant-of-any
  # Checks if a given file descends of one of the given paths.
  #
  # :: [String] -> String -> Bool
  descendant-of-any = (paths, file) -->
    paths.some (descendant-of file)


  ### λ filter-descendants
  # Filters the list removing descendants of certain paths.
  #
  # :: [String] -> [String] -> [String]
  filter-descendants = (paths, files) -->
    files.filter ((not) . (descendant-of-any paths))


  ### λ file-type
  # Returns a type tag for the file.
  #
  # :: String -> FileType
  file-type = (file) ->
    stat = fs.stat-sync file
    switch
    | stat.is-directory! => \directory
    | stat.is-file!      => \file
    | otherwise          => \other
    

  ### λ remove
  # Removes the file/directory.
  #
  # :: String -> ()
  remove = (file) -> switch file-type file
    | \file      => do
                    fs.unlink-sync file
                    console.info "Removed file #file."
    | \directory => do
                    remove-dir file
                    console.info "Removed directory #file."
    | \other     => do
                    console.warn("Can't remove file \"#file\". It's neither a file nor a directory.")


  ### λ clean
  # Removes unused files from a project's tree.
  #
  # :: CleanConfig -> ()
  clean = (env) ->
    ignore = expand (env.ignore or [])
    files  = filter-descendants ignore, (expand (env.files or []))
    files.for-each remove
    console.log "All cleaned up."


  ### -- Tasks ---------------------------------------------------------
  whisper.task 'clean'
             , []
             , """Removes build artifacts and backup files from a project.

               This task will clean-up your project directory, by
               removing build artifacts and other
               automatically-generated files that clobber your file
               tree.

               You should specify which files to remove by configuring
               the `clean` task in your `.whisper` file. The
               configuration should conform to the following structure:

               
                   type Clean {
                     files : [Pattern]
                     ignore : [Path]
                   }

               
               You should always provide a list of Glob patterns for the
               files you want to remove, and optionally you can provide
               a list of paths this task should not touch.

               All paths are relative to the project's root.

               ## Example

               Removing the `build/` directory and all `.orig` backup
               files, but not touching anything inside `node_modules`.

                   module.exports = function(whisper) {
                     whisper.configure({
                       clean: { files: ['build/', '*.orig']
                              , ignore: ['node_modules/'] }
                     })
                   
                     require('whisper-clean')(whisper)
                   }
               """
             , (env) -> clean env.clean
