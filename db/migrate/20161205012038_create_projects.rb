class CreateProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :projects do |t|
      t.string :project_name
      t.string :description
      t.string :sub_title
      t.string :primary_image
      t.string :index_image
      t.string :github
      t.string :url
      t.string :tech
      t.timestamp :completion_date

      t.timestamps
    end
  end
end
