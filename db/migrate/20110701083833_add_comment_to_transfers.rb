class AddCommentToTransfers < ActiveRecord::Migration
  def self.up
    add_column :transfers, :comment, :string
  end

  def self.down
    remove_column :transfers, :comment
  end
end
