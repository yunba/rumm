require 'net/ssh'

class JobsController < MVCLI::Controller
  requires :compute
  requires :command
  requires :job

  def create
    template = Jobs::CreateForm
    argv = MVCLI::Argv.new command.argv
    form = template.new argv.options
    command.output.puts "Setting up new jenkins job: #{form.job_name} on server: #{server.name}."
    sleep(1)
    xml = job.job_template(form.job_repo, form.job_command)
    Net::SSH.start("#{server.ipv4_address}", "root") do |ssh|
      # 'ssh' is an instance of Net::SSH::Connection::Session
      ssh.exec! "echo '#{xml}' >> #{form.job_name}-config.xml"
      ssh.exec! "java -jar /home/jenkins/jenkins-cli.jar -s http://0.0.0.0:8080 create-job #{form.job_name} < #{form.job_name}-config.xml"
    end
    return server
  end

  private

  def server
    compute.servers.find {|s| s.name == params[:id]} or fail Fog::Errors::NotFound
  end
end