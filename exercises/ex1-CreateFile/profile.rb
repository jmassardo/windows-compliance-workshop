# Simple control to validate that the required
# file exists.

title "Required Files"

control "req-files-1" do                                   # A unique ID for this control
  impact 1.0                                               # The criticality, if this control fails.
  title "All systems should have a tag file"               # A human-readable title
  desc "This file tags a system so we know Chef built it." # Metadata and other knowledge about this requirement/control
  describe file("c:/windows/temp/chef.txt") do             # The actual test
    it { should exist }
  end
end
