class AddPageKeywordsAndPageDescriptionToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :page_keywords, :string
    add_column :topics, :page_description, :string
  end
end
