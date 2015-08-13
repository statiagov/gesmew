---
title: Navigating the Source
section: source-code
---

## Overview

This guide covers obtaining and running the source code. This is
primarily for developers who are interested in contributing code to the
Gesmew project or fixing the source code themselves. It is not necessary
to have a copy of the source code to run Gesmew. This guide covers the
following topics:

-   How Gesmew uses Git and GitHub to manage source code
-   The various gems that comprise the Gesmew source code
-   Building the gem from the source

## Git

The Gesmew source code is currently maintained in a
[Git](http://git-scm.com/) repository. Git is a distributed version
control system (DVCS)

The authoritative git repository is hosted by
[GitHub](https://github.com/) and is located in the
[gesmew](https://github.com/gesmew/gesmew/tree/master) repository. You can
clone the git repository using the following command:

```bash
$ git clone git://github.com/gesmew/gesmew.git
```

***
If you are planning on contributing to Gesmew you should create a
fork through GitHub and push fixes to clearly labeled branches (see the
[Contributors Guide](contributing) for details.)
***

### Browsing the Repository and/or Downloading the Source Code

You can easily browse the repository through GitHub's excellent [visual
interface](https://github.com/gesmew/gesmew/tree/master). GitHub also
contains a link to download a tarball copy of the latest source code as
well as links to [previous
versions](https://github.com/gesmew/gesmew/tags).

### Git on Windows

There are some well developed Git clients for Windows now. If you are on
a Windows box you might want to check out the
[msysgit](http://code.google.com/p/msysgit/) project.

### Monitoring Changes in the Source

If you would like to keep up to date on changes to the source you can
subscribe to the GitHub
[RSS feed](https://github.com/feeds/gesmew/commits/gesmew/master) and you
will be notified of all the commits.

## Bundler

Gesmew uses the very excellent [bundler](http://gembundler.com/) gem to
manage its dependencies. We are assuming you have basic familiarity with
bundler. A detailed explanation of bundler can be found on [Bundler's
site](http://gembundler.com/).

You can install the gem dependencies for Gesmew after cloning the
repository using this Bundler-provided command:

```bash
$ bundle install
```

This allows you to quickly and painlessly have the exact gem depedencies
you need to work with Bundler.

## Layout and Structure

### Collection of Gems

The Gesmew gem itself is very minimal and consists mostly of a collection
of gems. These gems are maintained together in a single GitHub
repository and new versions of the gems are shipped with each new Gesmew
release. The official documentation (which you are reading now) covers
functionality provided by each of these gems.

Within the Gesmew source, each of the gems is organized into
subdirectories as follows:

| Gem            | Directory | Description               |
| :--------------| :---------| :-------------------------|
| gesmew_api      | api       | Provides REST API access  |
| gesmew_backend  | backend   | Backend functionality     |
| gesmew_cmd      | cmd       | Command line utility for installing Gesmew and creating extensions |
| gesmew_core     | core      | Core functionality - all other gems depend on this gem |
| gesmew_dash     | dash      | Simple overview dashboard |
| gesmew_frontend | frontend  | Customer-facing functionality    |
| gesmew_sample   | sample    | Sample data and images    |

### Use of Rails Engines

Each of the gems in Gesmew makes use of Rails Engines. This functionality
was introduced in Rails 3.0 and allows Engines to behave in a manner
similar to fully-functional applications. Relying on this mechanism
provides several advantages:

#### An Intuitive Mechanism for Customization

Default Gesmew functionality is provided via the Rails engine gems.
Engines can provide several aspects traditionally associated with a
Rails application including (but not limited to):

-   Models, views and controllers
-   Routes
-   Helpers
-   Rake tasks
-   Generators
-   Locales

All of these elements can be overridden in the main Rails application.
Therefore, it is relatively simple to add Gesmew to your Rails
application and then customize it further by supplying your own elements
in that same application. A full discussion of Rails Engines is not
appropriate here. Please [consult the Rails Guides](http://edgeguides.rubyonrails.org/engines.html) for more information.

#### Simple Distribution and Installation as Gems

Using a Gesmew gem is as simple as adding it to your *Gemfile*:

```ruby
gem 'gesmew_core', '2.1.0'
```

Distribution of Gesmew (and its extensions) is also consistent with Rails
standards and modularity (see next.)

#### Consistency With a Rails Standard

Prior to version 0.30.0, Gesmew used a complex custom mechanism for
implementing "engine-like" functionality. While it was difficult to
strip this functionality out of Gesmew, the benefits are well worth it.
Gesmew now receives all of the massive testing and attention to detail
that comes for free when using the Rails core engine functionality,
rather than a custom solution.

#### Modularity

There are differing opinions on what belongs in the "core." People often express their opinion that Gesmew is either "getting too fat" or
"lacks basic features." By relying on these engines (and distributing
them as gems), developers are free to use only the parts of Gesmew that
they find useful. For instance, this would allow you to omit promotions
functionality or to replace the authentication mechanism.

For example, if you were to specify something like this in your
application's *Gemfile*:

```ruby
gem 'gesmew', '2.1.0'
```

It would require all the individual parts of Gesmew. However, if you only
wanted to require the "core" and "backend" parts of Gesmew, you would do
this:

```ruby
gem 'gesmew_core', '2.1.0'
gem 'gesmew_backend', '2.1.0'
```

## Building a Sandbox Application

When working with the Gesmew source you may find yourself wanting to see
how the code performs in the context of an actual application. This is
due to the fact that Gesmew is intended to be distributed as a gem and is
not designed to be run as a standalone application. Gesmew includes a
helpful Rake task for setting up such a test application.

To run this Rake task, go into the root of the Gesmew project and run
this command:

```bash
$ bundle exec rake sandbox
```

This will create a barebones rails application configured with the Gesmew
gem. It runs the migrations for you and sets up the sample data. The
resulting `sandbox` folder is already ignored by `.gitignore` and it is
deleted and rebuilt from scratch each time the Rake task runs.

## Building the Gem from the Source

The Gesmew gem can easily be built from the source. Run these two
commands in the root of the Gesmew project to do this:

```bash
$ bundle exec rake clean
$ bundle exec rake gem
```

Most likely you will want to build and install all of the related gems.
Fortunately, there is a simple Rake task for that.

```bash
$ bundle exec rake gem:install
```

You can also build just one specific gem.

```bash
$ cd core
$ bundle exec rake gem
```

## Tips for Working with the Source

### Using the "Edge" Code

If you are interested in simply using the latest edge code (as opposed
to contributing to it) then the simplest thing to do is add a *:github*
directive to your *Gemfile* and point it at the master branch.

```ruby
gem 'gesmew', :github => 'gesmew/gesmew'
```

This will effectively use the latest code from the Git repository at the
time you run *bundle install*. This version of the code will be "frozen"
in your *Gemfile.lock* and will ensure that anyone else using your
project code is using the exact same version of the Gesmew code as you
are. You will need to update the bundle if you want to update to code
that is newer since the last time you updated.

```bash
$ bundle update
```

### Developing on the "Edge"

If you plan on using the edge code but also contributing back to Gesmew,
then you may be interested in the following approach. Create your Rails
app that will be using the Gesmew gem in a directory that has the same
parent as a locally cloned version of the Gesmew source. Then simply use
the following in your Gemfile.

```ruby
gem 'gesmew', :path => '../gesmew'
```

***
See the excellent [Bundler documentation](http://gembundler.com) for more details.
***

### "-stable" branches

The Gesmew Git repository also contains stable branches for each minor Gesmew
version. For instance, there is a 2-1-stable branch which contains the latest
work for the 2.1.x branch of Gesmew. You may also decide to use this branch if you want the latest and greatest version of Gesmew:

```ruby
gem 'gesmew', :github => 'gesmew/gesmew', :branch => '2-1-stable'
```

Similarly, all main Gesmew extensions use this versioning scheme as well. For example, here's a line that would be used for `gesmew_auth_devise`:

```ruby
gem 'gesmew_auth_devise', :github => 'gesmew/gesmew_auth_devise', :branch => '2-1-stable'
```

!!!
While the best efforts of the Gesmew team are made to keep stable branches
stable, there has been situations in the past where changes required for a
net-positive result over the entire community have affected some applications
or extensions. If a change to a stable branch does break your application or
an extension, please report those breakages on the appropriate GitHub page.
!!!

### Creating Extensions

Gesmew provides a convenient generator for helping you to get started
with extensions.

```bash
$ gesmew extension foo
```

***
You need to have the Gesmew gem installed in inspection to use the `gesmew` command.
***

Please see the [Creating Extensions](extensions_tutorial) guide for more details.
