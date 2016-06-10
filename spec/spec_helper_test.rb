require 'rspec'
require 'serverspec'
require 'docker'

#Include Tests
base_spec_dir = Pathname.new(File.join(File.dirname(__FILE__)))
Dir[base_spec_dir.join('../../drone-tests/shared/**/*.rb')].sort.each { |f| require_relative f }

if not ENV['IMAGE'] then
  puts "You must provide an IMAGE env variable"
end

LISTEN_PORT=8080
MYSQL_PORT=3306

describe "Dockerfile" do
  before(:all) do
    @image = Docker::Image.get(ENV['IMAGE'])
  end

  describe "DockerContainer" do
    before(:all)  do
      @container = Docker::Container.create(
        'Image'       => @image.id,
        'User'     => '100000',
        'HostConfig'   => {
          'PortBindings' => {
            "#{LISTEN_PORT}/tcp" => [ { 'HostPort' => "#{LISTEN_PORT}" } ],
            "#{MYSQL_PORT}/tcp" => [ { 'HostPort' => "#{MYSQL_PORT}" } ]
          }
        }
      )
      @container.start
      set :backend, :docker
      set :docker_container, @container.id
      puts "Waiting for 30 seconds for prescript to complete."
      sleep 30
    end

    describe "tests" do
      include_examples 'docker-ubuntu-16'
#      include_examples 'docker-ubuntu-16-nginx-1.10.0'
#      include_examples 'php-7.0-tests'
      include_examples 'phpmyadmin-4.6-tests'
      include_examples 'mysql-tests'
    end  
  
    after(:all) do
      @container.kill
      @container.delete(:force => true)
    end
  end
end
