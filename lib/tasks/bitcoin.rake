namespace :bitcoin do
  desc "Synchronizes the transactions in the client with the transactions stored in the database"
  task :synchronize_transactions => :environment do
    Lockfile.lock(:synchronize_transactions) do
      BitcoinTransfer.synchronize_transactions!
    end
  end

  desc "Backs the wallet up and sends it through e-mail"
  task :backup_wallet => :environment do
    Lockfile.lock(:backup_wallet) do
      recipient = YAML::load(File.open(File.join(Rails.root, "config", "backup.yml")))["recipient"]

      # Check that we have GPG in the path and that the key exists
      if system("gpg --version") and system("gpg --fingerprint \"#{recipient}\"")
        temp_file = File.join(Dir.tmpdir, (rand * 10 ** 9).to_i.to_s)
        Bitcoin::Client.instance.backup_wallet temp_file
        system("gpg -e -r \"#{recipient}\" #{temp_file}")
        BackupMailer.wallet_backup(recipient, "#{temp_file}.gpg").deliver
        system("rm -f #{temp_file}*")
      end
    end
  end
  
  desc "Backs the DB up and uploads it through FTP"
  task :backup_db => :environment do
    Lockfile.lock(:backup_db) do
      require 'net/ftp'
      require 'net/http'
      require 'uri'
      require 'yaml'

      servers = YAML::load(File.open(File.join(Rails.root, "config", "backup.yml")))["ftp_servers"]
      
      unless !servers.blank?
        backup_filename = "#{DateTime.now.strftime("%Y_%m_%d_%H_%M")}_bc_#{RAILS_ENV}.sql"
        backup_file = File.join(Rails.root, "tmp", backup_filename)
        compressed_file = backup_file + ".tar.bz2"

        db_settings = YAML::load_file(File.join(Rails.root, "config/database.yml"))[Rails.env]

        mysql_user = db_settings['username']
        mysql_password = db_settings['password']
        mysql_database = db_settings['database']

        system("mysqldump --user=#{mysql_user} --password=#{mysql_password} --database #{mysql_database} --add-drop-database > #{backup_file}")
        system("cd #{File.dirname(backup_file)} && tar -cj #{backup_filename} > #{backup_filename}.tar.bz2")

        servers.each do |server|
          begin
            Net::FTP.open(server["host"]) do |ftp|
              ftp.login(server["username"], server["password"])
              ftp.put(compressed_file)
            end
          rescue Exception => e
            puts("\n** Error while uploading backup to #{server["host"]}\n** Error was : #{e.message}\n")
          end
        end
        system("rm -f #{backup_file}")
        system("rm -f #{compressed_file}")
      end    
    end
  end
  
  desc "Processes pending invoices and update their state if necessary"
  task :process_pending_invoices => :environment do
    Lockfile.lock(:process_pending_invoices) do
      Invoice.process_pending
    end
  end

  desc "Prunes pending invoices older than 48h"
  task :prune_old_pending_invoices => :environment do
    Invoice.
      where("created_at < ?", DateTime.now.advance(:hours => -48)).
      where(:state => "pending").
      delete_all
  end
end