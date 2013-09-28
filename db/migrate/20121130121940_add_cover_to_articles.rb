class AddCoverToArticles < ActiveRecord::Migration
  def change
    # ariticles_cover
    add_column :articles, :cover_file_name, :string
    add_column :articles, :cover_content_type, :string
    add_column :articles, :cover_file_size, :integer
    add_column :articles, :cover_updated_at, :datetime
  end
end
