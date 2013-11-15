class Jenkins::CreateForm < MVCLI::Form

  input :git_name, String, default: 'Jenkins'
  input :git_email, String, default: 'admin@jenkins.com'

end
