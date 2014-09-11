# Cocoapods::Plugins Changelog

## Master

* Added a reminder to add plugin to `plugins.json` once released (fix #27)
  [Olivier Halligon](https://github.com/AliSoftware)

* Print out the version of plugins when invoked with `--verbose`
  [David Grandinetti](https://github.com/dbgrandi)

## 0.2.0

* Migrating to new syntax of CLAide::Command#arguments (fix #23)
  [Olivier Halligon](https://github.com/AliSoftware)

* Printing URL of template used (fixes #21)  [Olivier Halligon]
  [Olivier Halligon](https://github.com/AliSoftware)

* `create` subcommand now prefixes the given name if not already (fix #20)
  [Olivier Halligon](https://github.com/AliSoftware)

## 0.1.1

* Making `pod plugins` an abstract command, with `list` the default subcommand (#11, #12)
  [Olivier Halligon](https://github.com/AliSoftware)
* Added `search` subcommand to search plugins by name, author and description. (#9)
  [Olivier Halligon](https://github.com/AliSoftware)
* Refactoring (#10, #13), improved output formatting (#8)
  [Olivier Halligon](https://github.com/AliSoftware)
* Fixing coding conventions and Rubocop offenses (#17)
  [Olivier Halligon](https://github.com/AliSoftware)

## 0.1.0

* Initial implementation.  
  [David Grandinetti](https://github.com/dbgrandi)
* Added `create` subcommand to create an empty project for a new plugin.
  [Boris Bügling](https://github.com/neonichu)
