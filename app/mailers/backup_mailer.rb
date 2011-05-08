class BackupMailer < ActionMailer::Base
  def wallet_backup(recipient, wallet)
    attachments["wallet_#{DateTime.now.strftime("%Y_%m_%d_%H_%M.dat.gpg")}"] = File.read(wallet)

    mail :to => recipient,
      :subject => (I18n.t :wallet_backup_subject, :date=>(I18n.l DateTime.now))
  end
end
