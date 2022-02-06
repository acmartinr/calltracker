class PagesController < ApplicationController
  if Rails.env.development?
    http_basic_authenticate_with name: "developer", password: "AapMRmH9ngFP"
  else
    http_basic_authenticate_with name: "testing", password: "5vdtzvdGNVus"
  end
end
