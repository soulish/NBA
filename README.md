# NBA
This is most of the backing code necessary to run my NBA statistical
analyses.  All of the code is written in Ruby and also uses the C++ package
ROOT, which can be obtained from root.cern.ch, although it is not necessary
to understand the basics of this code.

The file test.rb shows how an actual bit of analysis code
would look, although this is of course a very simple file.  We begin
by requiring the file 'rubyStuff.rb', which sets up the ROOT environment.
Then we require 'backbone.rb', and that file requires a ton of other
files, not all of which are present in the repository as they are
not necessary to understand the basics of the code.  The bulk of
the files are stored in the 'src/' directory, while the rest are
in the 'constants/' directory.

The 'src' directory contains files to set up the Player and Team
classes, as well as the Game and Season classes, which have subclasses
TeamGame and PlayerGame, and TeamSeason and PlayerSeason.  There are 
also several other classes set up which define how the stastics are kept,
like the Pct and Pcts classes.

The 'constants' directory contains a few files with constants that will
be used during runtime.  Not all of these files have been copied into this
repository.

The data being analyzed are kept in the 'players/' and 'teams/' directories.
Only one season of one team and one season for one player have been 
put in the respository as there are thousands of files.  They show how
the setup works.

