class CreateSlideshows < ActiveRecord::Migration
  def change
    create_table :slideshows do |t|
      t.string :ident, :null => false
      t.string :title
      t.text   :desc

      # settings
      t.string  :status
      t.string  :map_type
      t.integer :map_height
      t.integer :slide_height

      # stamps
      t.blamestamps
    end
  end
end
