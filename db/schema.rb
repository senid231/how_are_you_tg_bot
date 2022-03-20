# frozen_string_literal: true

class Schema < TelegramApp::RepositorySchema
  self.repository_class = Repository

  schema do
    create_table :users do
      primary_key :id
      column :external_id, :string, null: false
      column :username, :string, null: false
      column :first_name, :string
      column :last_name, :string
      column :location, :string
      column :wait_location, :boolean, default: false
      column :location_added_at, :timestamp
      column :help_request, :string
      column :wait_help_request, :boolean, default: false
      column :help_request_added_at, :timestamp
      column :created_at, :timestamp, null: false
      index :external_id, unique: true
    end

    create_table :groups do
      primary_key :id
      column :external_id, :string, null: false
      column :title, :string, null: false
      column :created_at, :timestamp, null: false
      index :external_id, unique: true
    end

    create_table :users_groups do
      primary_key :id
      foreign_key :user_id, :users, null: false
      foreign_key :group_id, :groups, null: false
      column :created_at, :timestamp, null: false
      index [:user_id, :group_id], unique: true
    end
  end
end
