windows_feature ['web-server, web-webserver'] do
  action :install
  install_method :windows_feature_powershell
end