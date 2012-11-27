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

      t.timestamps
    end
  end
end
