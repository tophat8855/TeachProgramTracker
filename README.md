# TeachProgramTracker
TEACH Program Software Stack

Using ruby 2.4.0 and rails 5.0.2

Setting up assuming you have rails and ruby setup.  If you're having major issues, ensure that your global ruby
is pointing somewhere that makes sense.  '''which ruby''' can help with that.

If there's a problem and you're using rvm, try:
'''rvm --default use ruby-2.4.0'''

If on an ubuntu distro, install postgresql along with your rails implementation by:

'''apt-get -y install postgresql postgresql-contrib libpq-dev'''

To make sure that it's running, try:
'''sudo su - postgres && psql'''

To run this rails app locally, run

'''sudo su && su postgres'''
''''createuser -s --username=postgres YOURUSERNAME'''
This will create a superuser by connecting as postgres.

Run:
''''rake db:create'''

from within the root of this repository.

If you get LoadError: cannot load such file -- bundler/setup, run:
'''gem install bundler'''

If everything is working correctly, rake db:create will return:
'''Created database 'TeachProgramTracker_development'''
'''Created database 'TeachProgramTracker_test'''

If missing gems, run bundle install.

Before running the rails server, make a secret key in secrets.yml in the config folder.

'''development:
  secret_key_base: "Anything you like"
'''

Run 'rails server' to see it in localhost:3000.

**Testing**

Please run tests before committing and pushing.
```bundle exec rspec```
