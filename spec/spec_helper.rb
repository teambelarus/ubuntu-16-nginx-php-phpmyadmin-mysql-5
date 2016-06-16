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
CONTAINER_START_SLEEP=120

describe "Dockerfile" do
  before(:all) do
    puts "Building image"
    @image = Docker::Image.get(ENV['IMAGE'])
    puts "Finished building image"
    set :backend, :docker

   @container = Docker::Container.create(
    'Image'          => @image.id,
    'User'           => '100000',
    'HostConfig'     => {
      'PortBindings' => {
        "#{LISTEN_PORT}/tcp" => [ { 'HostPort' => "#{LISTEN_PORT}" } ],
        "#{MYSQL_PORT}/tcp"  => [ { 'HostPort' => "#{MYSQL_PORT}" } ]
      }
    }
   )
  
   @container.start
      
   ready_regex = /mysqld_safe Starting mysqld daemon with databases from \/var\/lib\/mysql/
   counter=0
   while counter < CONTAINER_START_SLEEP do
     match = @container.logs({ :stdout => true }).split("\n").grep(ready_regex)
     unless match.empty? then
       puts "MySQL should now be ready, starting tests."
       break
     end
     puts "Sleeping for 5 seconds while MySQL starts up...#{counter}/#{CONTAINER_START_SLEEP}"
     sleep 5
     counter += 5
   end
   if counter >= CONTAINER_START_SLEEP then
      puts "TIMEOUT during startup."
      @container.kill
      @container.delete(:force => true)
      exit 1
   end

     puts @container.logs({ :stdout => true, :stderr => true })
     
     set :docker_container, @container.id
   end

   describe "tests" do
     include_examples 'docker-ubuntu-16'
#     include_examples 'docker-ubuntu-16-nginx-1.10.0'
#     include_examples 'php-7.0-tests'
     include_examples 'phpmyadmin-4.6-tests'
     include_examples 'mysql-tests'
   end  
  
   after(:all) do
     @container.kill
     @container.delete(:force => true)
   end
  end
