require File.join(File.dirname(__FILE__),'../../../lib/brightbox/database_yml/mysql')

require 'tempfile'
def make_temp_file(contents)
  localfile = Tempfile.new('rspec')
  localfile << contents
  localfile.close
  localfile.path
end

def valid_production
  make_temp_file %Q{
  production:
    adapter: mysql
    database: fred
    host: somewhere.else.com
  }
end

def valid_database_yml
  make_temp_file %Q{
  development:
    database: fred_app_development
    username: fred
    host: sqlreadwrite.brightbox.net
    password: jim
    adapter: mysql

  test:
    username: fred
    host: sqlreadwrite.brightbox.net
    password: jim
    adapter: mysql
    database: fred_app_test

  production:
    username: fred
    host: sqlreadwrite.brightbox.net
    password: jim
    adapter: mysql
    database: fred_app_production
  }
end

def bad_database
  make_temp_file %Q{
  production:
    database: fred
    username: hello
    host: sqlreadwrite.brightbox.net
  }
end

def missing_details
  make_temp_file %Q{
  production:
    database: #{@username}_test_production
  }
end

def appname
  "testapp"
end

describe Brightbox::DatabaseYml::Mysql do

  it "should require a filename when created" do
    lambda {
      @fred=Brightbox::DatabaseYml::Mysql.new
    }.should raise_error(ArgumentError)
  end

  it "should not work with a missing filename" do
    lambda {
      @fred=Brightbox::DatabaseYml::Mysql.new(appname,nil)
    }.should raise_error
  end
  
  it "should raise ArgumentError if not a YAML file" do
    lambda {
      @fred=Brightbox::DatabaseYml::Mysql.new(appname,"/etc/services")
    }.should raise_error(ArgumentError)
  end

  describe "when dealing with missing my.cnf ini file" do
    before(:each) do
      Brightbox::DatabaseYml::Mysql.stub!(:mysql_config_file).and_return('fred')
    end

    it "should raise an error if details are required" do
        @fred=Brightbox::DatabaseYml::Mysql.new(appname,missing_details)
        @fred.errors.should_not be_empty
    end

    it "should not raise an error if details are not required" do
        @fred=Brightbox::DatabaseYml::Mysql.new(appname,valid_production)
        @fred.errors.should be_empty
    end
  end

  describe "when dealing with a correct my.cnf ini file" do
    before(:all) do
      @username = "username"
      @password = "password"
      @mycnf = make_temp_file %Q{
[client]
user=#{@username}
password=#{@password}
host=sqlreadwrite.brightbox.net
      }
    end

    before(:each) do
      Brightbox::DatabaseYml::Mysql.stub!(:mysql_config_file).and_return(@mycnf)
    end

    it "should object to incorrect database name" do
      @fred = Brightbox::DatabaseYml::Mysql.new(appname,bad_database)
      @fred.errors.should_not be_empty
    end

    it "should register no change with a correct database.yml" do
      @fred = Brightbox::DatabaseYml::Mysql.new(appname,valid_database_yml)
      @fred.should_not be_changed
    end

    it "should create production with a missing but writeable filename" do
      @fred = Brightbox::DatabaseYml::Mysql.new(appname,'/tmp/fred12345')
      @fred.errors.should be_empty
    end

  end



end

