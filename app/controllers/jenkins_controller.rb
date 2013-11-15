require "tmpdir"
require "open3"
require "bundler"

class JenkinsController < MVCLI::Controller
  requires :compute
  requires :naming
  requires :command

  def create
    template = Jenkins::CreateForm
    argv = MVCLI::Argv.new command.argv
    form = template.new argv.options
    command.output.puts "Setting up a chef kitchen in order to install jenkins on your server."
    command.output.puts "This could take a while...."
    sleep(1)
    tmpdir = Pathname(Dir.tmpdir).join 'chef_kitchen'
    FileUtils.mkdir_p tmpdir
    Dir.chdir tmpdir do
      Bundler.with_clean_env do
        File.open('Gemfile', 'w') do |f|
          f.puts 'source "https://rubygems.org"'
          f.puts 'gem "knife-solo", ">= 0.3.0pre3"'
          f.puts 'gem "berkshelf"'
        end
        execute "bundle install --binstubs"
        execute "bin/knife solo init ."
        FileUtils.rm "Berksfile"
        File.open 'Berksfile', 'w' do |f|
          f.puts "site :opscode"
          f.puts ""
          f.puts "cookbook 'runit', '>= 1.1.2'"
          f.puts "cookbook 'jenkinsbox', github: 'hayesmp/jenkins-rackbox-cookbook'"
        end
        execute "bin/berks install --path cookbooks/"
        execute "bin/knife solo prepare root@#{server.ipv4_address}"
        File.open('nodes/host.json', 'w') do |f|
          f.puts("{\"run_list\":[\"recipe[build-essential]\",\"recipe[jenkinsbox::postgresql]\",\"recipe[jenkinsbox]\",\"recipe[jenkinsbox::jenkins]\"],\"jenkinsbox\":{\"build_essential\":{ \"compiletime\":true},\"jenkins\":{\"git_name\":\"#{form.git_name}\",\"git_email\":\"#{form.git_email}\",\"ip_address\":\"#{server.ipv4_address}\", \"host\":\"#{server.name}\"},\"ruby\":{\"versions\":[\"2.0.0-p247\"],\"global_version\":\"2.0.0-p247\"},\"apps\":{\"unicorn\":[{\"appname\":\"app1\",\"hostname\":\"app1\"}]},\"db_root_password\":\"iloverandompasswordsbutthiswilldo\", \"databases\":{\"postgresql\":[{\"database_name\":\"app1_production\",\"username\":\"app1\",\"password\":\"app1_pass\"}]}}}")
        end

        FileUtils.rm_rf "#{server.ipv4_address}.json"
        FileUtils.mv "nodes/host.json", "nodes/#{server.ipv4_address}.json"
        execute "bin/knife solo cook root@#{server.ipv4_address} -V"
      end
    end
    return server
  end

  private

  def execute(cmd)
    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      while line = stdout.gets
        command.output.puts "   " + line
      end
      exit_status = wait_thr.value
      unless exit_status.success?
        abort "FAILED !!! #{cmd}"
      end
    end
  end

  def server
    compute.servers.find {|s| s.name == params[:id]} or fail Fog::Errors::NotFound
  end
end