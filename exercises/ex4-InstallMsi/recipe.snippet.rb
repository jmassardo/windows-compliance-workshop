windows_package '7zip' do
  source 'http://www.7-zip.org/a/7z1900-x64.msi'
  remote_file_attributes ({
    :path => 'c:/windows/temp/7zip.msi' #,
    # :checksum => ' A7803233EEDB6A4B59B3024CCF9292A6FFFB94507DC998AA67C5B745D197A5DC'
  })
end

# Get-FileHash -Algorithm SHA256 .\7z1900-x64.msi 