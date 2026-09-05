class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :timezone, :string, null: false, default: "UTC"
    add_column :users, :week_start, :integer, null: false, default: 1
    add_column :users, :name, :string
  end
end
