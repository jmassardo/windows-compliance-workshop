# Simple control to validate that the required
# registry keys exist.

title "Required Registry Keys"

control "req-keys-1" do                                    # A unique ID for this control
  impact 1.0                                               # The criticality, if this control fails.
  title "All systems should have a Legal notice caption"   # A human-readable title
  desc "We are required to display legal notices to any user that logs in." # Metadata and other knowledge about this requirement/control
  describe registry_key('HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System') do
    its('legalnoticecaption') { should eq "WARNING!" }
  end
end

control "req-keys-2" do                                    # A unique ID for this control
  impact 1.0                                               # The criticality, if this control fails.
  title "All systems should have a Legal notice text"   # A human-readable title
  desc "We are required to display legal notices to any user that logs in." # Metadata and other knowledge about this requirement/control
  describe registry_key('HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System') do
    its('legalnoticetext') { should eq "This is a protected system. If you are not an authorized user, log off immediately!" }
  end
end
