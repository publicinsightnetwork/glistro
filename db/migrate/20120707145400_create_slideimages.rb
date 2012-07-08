class CreateSlideimages < ActiveRecord::Migration
  def up
    create_table :slideimages do |t|
      t.integer :slide_id

      # attached image
      t.has_attached_file :image

      # stamps
      t.blamestamps
    end

    drop_attached_file :slides, :image
  end

  def down
    drop_table :slideimages

    change_table :slides do |t|
      t.has_attached_file :image
    end
  end
end
