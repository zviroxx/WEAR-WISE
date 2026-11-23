class CreateOutfits < ActiveRecord::Migration[8.1]
  def change
    create_table :outfits do |t|
      t.string :name
      t.string :season
      t.string :image
      t.text :details

      t.timestamps
    end
  end
end
