class CreateServerDroppers < ActiveRecord::Migration
  def change
    create_table :server_droppers do |t|
      t.string :host
      t.integer :port

      t.timestamps
    end
  end
end
