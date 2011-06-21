# Naive implementation of a lock file mechanism should be sufficient for
# long running rake tasks
module Lockfile
  def self.lock(base_name, &block)
    file_name = File.join(Rails.root, "tmp", "#{base_name.to_s}.lock")
    
    unless File.exists?(file_name)
      # Just in case the temp directory does not exist
      FileUtils.mkdir_p(File.join(Rails.root, "tmp"))
      
      File.open(file_name, "w") { |f| f.write("Locked by process #{$$}") }      
      block.call
      File.unlink(file_name)
    end
  end
end
