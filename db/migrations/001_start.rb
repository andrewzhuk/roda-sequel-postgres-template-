# frozen_string_literal: true

Sequel.migration do
  change do
    run 'CREATE EXTENSION btree_gin'
    run 'CREATE EXTENSION pg_trgm'

    create_table(:users) do
      primary_key :id
      # Default one is an customer, ADMIN_ROLE CUSTOMER_ROLE for each user stored roles in integer.
      column :role, :smallint, null: false, default: 1
      column :password_failure_number, :smallint, null: false, default: 0
      column :email, :text, null: false
      column :username, :text, null: false
      column :first_name, :text
      column :last_name, :text
      column :password_digest, :text, null: false
      column :reset_password_token, :text
      column :confirmation_token, :text
      column :unconfirmed_email, :text
      column :unlock_token, :text
      column :language, :text, default: 'en', null: false
      column :confirmed_at, :timestamp
      column :last_login, :timestamp
      column :last_online, :timestamp
      column :password_failure_time, :timestamp
      column :reset_password_sent_at, :timestamp
      column :confirmation_sent_at, :timestamp
      column :banned_at, :timestamp
      column :locked_at, :timestamp
      column :updated_at, :timestamp, default: Sequel::CURRENT_TIMESTAMP, null: false
      column :created_at, :timestamp, default: Sequel::CURRENT_TIMESTAMP, null: false

      index %i[email role], unique: true
      index :reset_password_token, unique: true
      index :unlock_token, unique: true
      index :username, unique: true
      index :created_at
    end

    create_table(:sessions) do
      primary_key :id
      foreign_key :user_id, :users, type: :bigint, null: false
      column :ip_address, :varchar, size: 50, null: false
      column :user_agent, :varchar, size: 200, null: false
      column :fingerprint, :varchar, size: 100 # , null: false
      column :token, :text # , null: false
      column :expired_at, :timestamp # , null: false # for future...
      column :signed_in_at, :timestamp, null: false
      column :signed_out_at, :timestamp

      index :ip_address
      index :user_agent
      index :fingerprint
      index :user_id
    end

    create_table(:posts) do
      primary_key :id
      foreign_key :last_actor_id, :users, type: :bigint, null: false
      foreign_key :user_id, :users, type: :bigint, null: false # The person who created the post.
      foreign_key :verified_by, :users, type: :bigint
      foreign_key :declined_by, :users, type: :bigint
      foreign_key :original_id, :posts, type: :bigint # if post is translated version refering to original post
      column :edit_count, :integer, null: false, default: 0
      column :active, :boolean, default: true # Activate the post by admin/author - true/false.
      column :visible, :boolean, default: true # Show the post in the public, if the rules allow it  - true/false.
      column :token, :text, null: false
      column :slug, :text, null: false
      column :lang, :text, null: false
      column :state, :smallint, null: false # CREATED_STATE, ... stored in integer.
      column :title, :text # Author writes his title in text field
      column :title_alias, :jsonb, null: false, default: '{}'
      column :body, :text # Author writes his body in text editor
      column :last_action, :text, null: false
      column :verified_at, :timestamp
      column :declined_at, :timestamp
      column :deleted_at, :timestamp # Author/Admin can mark as deleted.
      column :updated_at, :timestamp, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :created_at, :timestamp, null: false, default: Sequel::CURRENT_TIMESTAMP

      index :active
      index :token
      index :last_actor_id
      index :title, unique: true
      index :slug, unique: true
      index :user_id
      index :updated_at
      index :created_at
    end

    create_table(:posts_users) do
      primary_key %i[post_id user_id]
      foreign_key :user_id, :users, type: :bigint, null: false
      foreign_key :post_id, :posts, type: :bigint, null: false
      column :interaction, :text

      index %i[user_id post_id]
    end
  end
end
