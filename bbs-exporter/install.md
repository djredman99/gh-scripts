## Help file for installing bbs-exporter

### Lessons I have learned:

- Using an Ubuntu 20.04 machine as this will default to installing ruby 2.7.0 (which bbs-exporter has a spec file of 2.4.0 < 2.7.0
   + Not tested, but 22.04 usins 3.0.2 as default ruby, perhaps you can change the spec file in the next bullet below to include 3.0.2...ruby ">= 2.4.0", "<= 3.0.2":'
- Need to change the Gemfile in root to include 2.7.0 by adding an '=' after the "<" symbol -   ruby ">= 2.4.0", "<= 2.7.0":'
- These need to be installed:
   + sudo apt install make
   + sudo apt install gcc
   + sudo apt install rubygems
   + sudo apt-get install libsqlite3-dev
   + sudo apt-get install libncurses-dev
