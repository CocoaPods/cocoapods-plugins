# Cocoapods plugins

[![Build Status](https://img.shields.io/travis/CocoaPods/cocoapods-plugins.svg)](https://travis-ci.org/CocoaPods/cocoapods-plugins)
[![Coverage Status](https://coveralls.io/repos/CocoaPods/cocoapods-plugins/badge.png)](https://coveralls.io/r/CocoaPods/cocoapods-plugins)
[![Code Climate](https://img.shields.io/codeclimate/github/CocoaPods/cocoapods-plugins.svg)](https://codeclimate.com/github/CocoaPods/cocoapods-plugins)

CocoaPods plugin which shows info about available CocoaPods plugins or helps you get started developing a new plugin. Yeah, it's very meta.

## Installation

    $ gem install cocoapods-plugins

## Usage

#####List plugins

    $ pod plugins

List all known plugins (according to the list hosted on github.com/CocoaPods/cocoapods.org)

#####Search plugins

    $ pod plugins search QUERY

Searches plugins whose name contains the given text (ignoring case). With --full, it searches by name but also by author and description.

#####Create a new plugin

    $ pod plugins create NAME [TEMPLATE_URL]

Creates a scaffold for the development of a new plugin according to the CocoaPods best practices.
If a `TEMPLATE_URL`, pointing to a git repo containing a compatible template, is specified, it will be used in place of the default one.

## Get your plugin listed

The list of plugins is in the cocoapods.org repository at [https://github.com/CocoaPods/cocoapods.org/blob/master/data/plugins.json](https://github.com/CocoaPods/cocoapods.org/blob/master/data/plugins.json).

To have your plugin listed, submit a pull request that adds your plugin details.

