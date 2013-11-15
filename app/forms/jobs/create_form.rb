class Jobs::CreateForm < MVCLI::Form
  requires :naming

  input :job_repo, String, default: 'https://github.com/hayesmp/railsgirls-app.git'
  input :job_command, String, default: 'bundle exec rake'
  input :job_name, String, default: 'job1'

end
