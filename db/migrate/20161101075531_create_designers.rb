class CreateDesigners < ActiveRecord::Migration
  def change
    create_table :designers do |t|
      t.string :username
      t.string :email

      t.timestamps null: false
    end
  end
end
