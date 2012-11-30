class CreateServers < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.integer :port
      t.string :name
      t.string :host
      t.string :password
      t.boolean :private
      t.boolean :buffer_replay
      t.integer :pid
      # reasoning for not using devise
      # small app
      # avoid users table (hacks)
      t.string :email # login
      t.string :pass # md5 hash

      t.timestamps
    end
  end
end
