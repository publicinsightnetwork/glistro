class CreateSlideimages < ActiveRecord::Migration
  def up
    create_table :slideimages do |t|

      # attached image
      t.has_attached_file :image

      # stamps
      t.blamestamps
    end

    drop_attached_file :slides, :image

    # add an inverse id to slides
    add_column :slides, :slideimage_id, :integer
  end

  def down
    drop_table :slideimages

    change_table :slides do |t|
      t.has_attached_file :image
    end

    remove_column :slides, :slideimage_id
  end
end
