# PHP Server

An Atom package to run PHP's built-in development server and display the log in a bottom pane. Can be started from any folder in the tree, the currently opened file, or the project root.

> :exclamation::exclamation::exclamation:
> This package is no longer maintained. Please fork or seek alternatives
> :exclamation::exclamation::exclamation:

![Screenshot](http://i.imgur.com/FhVtl9v.png)

## Requirements

PHP must be installed on your machine, version 5.4 or greater.

If `php` is not in your system PATH you will need to put in the full path to your PHP executable in the settings of this package.

For `Windows` operating systems, PHP will need to be installed and configured as per the instructions found at the following link: https://videlais.com/2019/05/11/using-atom-as-a-built-in-php-development-server/

## Commands

* `php-server:start` &mdash; Start / Restart PHP server from project path
* `php-server:start-tree` &mdash; Start / Restart PHP server from folder/file selected in tree
* `php-server:start-document` &mdash; Start / Restart PHP server from currently open file
* `php-server:stop` &mdash; Stop running PHP server
* `php-server:clear` &mdash; Clear message panel
