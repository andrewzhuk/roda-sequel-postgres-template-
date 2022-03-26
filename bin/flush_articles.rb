# frozen_string_literal: true

# !/usr/bin/env ruby

require_relative '../config/environment'

Application::Models::Post.flush!
