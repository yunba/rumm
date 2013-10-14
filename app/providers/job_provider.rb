require 'erubis'

class JobProvider
  def value
    self
  end

  def job_template(git_url, build_command)
    template = File.read(File.join(File.dirname(File.expand_path(__FILE__)), "../views/jobs/job_template.xml.erb"))
    template = Erubis::Eruby.new(template, :escape_html => false)
    #fail template.inspect
    template.result(:build_command => build_command, :git_url => git_url)
  end
end