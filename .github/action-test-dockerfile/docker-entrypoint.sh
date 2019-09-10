#!/bin/bash

bundle exec rails db:setup
bundle exec rails test
