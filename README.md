# TeachProgramTracker
TEACH Program Software Stack

Using ruby 2.4.0 and rails 5.0.2

Setting up:

If on an ubuntu distro, install postgresql along with your rails implementation by:

'apt-get -y install postgresql postgresql-contrib libpq-dev'

To make sure that it's running, 'sudo su - postgres && psql'

To run this rails app locally, run 'sudo su && su postgres' and 'createuser -s --username=postgres YOURUSERNAME' within the postgres shell.  This will create a superuser by connecting as postgres.

Make sure that your global ruby is pointing to whatever version of ruby rails was set up to use.  For rvm: 'rvm --default use ruby-2.4.0'

Run 'rake db:create' from within the root of this repository.

If you get LoadError: cannot load such file -- bundler/setup, run 'gem install bundler'

If everything is working correctly, rake db:create will return: 'Created database 'TeachProgramTracker_development'
Created database 'TeachProgramTracker_test'
'

If missing gems, run bundle install.

Run 'rails server' to see it in localhost:3000.
