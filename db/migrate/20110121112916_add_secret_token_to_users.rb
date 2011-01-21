class AddSecretTokenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :secret_token, :string
  end

  def self.down
    remove_column :users, :secret_token
  end
end
