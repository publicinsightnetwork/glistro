class CreateSlides < ActiveRecord::Migration
  def change
    create_table :slides do |t|
      t.integer :slideshow_id, :null => false
      t.string  :title
      t.text    :desc

      # attached image
      t.has_attached_file :image

      # settings
      t.integer :position
      t.string  :layout

      # geo location
      t.float :marker_lat
      t.float :marker_lng

      # stamps
      t.blamestamps
    end
  end
end
