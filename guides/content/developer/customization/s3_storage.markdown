---
title: "Use S3 for storage"
section: customization
---

## Overview

Currently the Gesmew backend does not give you the option anymore to configure s3 for image storage.
This guide covers how you can use S3 for storing assets in Gesmew.

### How to use S3

Start with adding AWS-SDK to your gemfile with:  `gem 'aws-sdk'`, then install the gem by running `bundle install`.

When that's done you need to configure Gesmew to use s3. You can add an initializer or just use the gesmew.rb initializer located at `config/intializers/gesmew.rb`.

```ruby
attachment_config = {

  s3_credentials: {
    access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    bucket:            ENV['S3_BUCKET_NAME']
  },

  storage:        :s3,
  s3_headers:     { "Cache-Control" => "max-age=31557600" },
  s3_protocol:    "https",
  bucket:         ENV['S3_BUCKET_NAME'],
  url:            ":s3_domain_url",

  styles: {
      mini:     "48x48>",
      small:    "100x100>",
      product:  "240x240>",
      large:    "600x600>"
  },

  path:           "/:class/:id/:style/:basename.:extension",
  default_url:    "/:class/:id/:style/:basename.:extension",
  default_style:  "product"
}

attachment_config.each do |key, value|
  Gesmew::Image.attachment_definitions[:attachment][key.to_sym] = value
end

```
Note that I use the `url: ":s3_domain_url"` setting, this enabled the DNS lookup for your images without specifying the specific zone endpoint. You need to use a bucket name that makes a valid subdomain. So do not use dots if you are planning on using the DNS lookup config.
