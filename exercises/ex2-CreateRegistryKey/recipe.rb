# Simple recipe to create the legal notice registry keys

registry_key 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System' do
  values [{
    name: "legalnoticecaption",
    type: :string,
    data: 'WARNING!'
  }]
  action :create
end

registry_key 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System' do
  values [{
    name: "legalnoticetext",
    type: :string,
    data: 'This is a protected system. If you are not an authorized user, log off immediately!'
  }]
  action :create
end