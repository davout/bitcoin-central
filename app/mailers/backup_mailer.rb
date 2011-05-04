class BackupMailer < ActionMailer::Base
  default :from => (t :support_from, :support_email=>(t :support_email))

  def wallet_backup(recipient, wallet)
    attachments["wallet_#{DateTime.now.strftime("%Y_%m_%d_%H_%M.dat.gpg")}"] = File.read(wallet)

    mail :to => recipient,
      :subject => (t :wallet_backup_subject, :date=>(l DateTime.now))
  end
end
