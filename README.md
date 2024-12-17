Jekyll Plugin: XML to JSON Converter
====================================

This plugin automatically converts XML data from specified URLs into JSON format and saves it to the Jekyll `_data` directory. It is designed to run only when the site is built in production (`JEKYLL_ENV=production`). This helps prevent dependency issues for those working locally without the required libraries.

Features
--------

-   Fetches XML data from remote URLs.
-   Converts XML data into JSON format.
-   Saves JSON output to `_data/` directory for use within the Jekyll site.
-   Only runs in the `production` environment to avoid unnecessary library dependencies locally.

Requirements
------------

-   Ruby gems:
    -   `nokogiri` (for parsing XML)
    -   `open-uri` (for fetching remote URLs)
    -   `json` (for generating JSON output)

Setup
-----

### Step 1: Add Required Gems to `Gemfile`

Add the following gems to your Jekyll site's `Gemfile` if they are not already included:

```
group :jekyll_plugins do
  gem 'nokogiri'
  gem 'open-uri'
  gem 'json'
end
```

Run `bundle install` after adding these gems to your `Gemfile` to ensure they are installed in the `production` environment.

### Step 2: Plugin Code

Include the following Ruby code in a new file at `_plugins/xml_to_json_generator.rb`:

```
require 'jekyll'  # Load Jekyll before checking the environment
require 'nokogiri'
require 'open-uri'
require 'json'

  module Jekyll
    class XMLToJSONGenerator < Generator
      safe true

      def generate(site)
        xml_sources = site.config['xml_to_json'] || []

        xml_sources.each do |source|
          xml_url = source['url']
          output_key = source['output']

          # Fetch and parse the XML data
          xml_data = Nokogiri::XML(URI.open(xml_url))

          # Convert the entire XML to a recursive hash
          json_data = xml_to_hash(xml_data.root)

          # Instead of saving to a file, inject directly into site.data
          site.data[output_key] = json_data
        end
      end

      private

      # Recursively converts an XML node and its children to a hash
      def xml_to_hash(node)
        result = {}

        # Add element's attributes
        node.attributes.each do |name, attr|
          result[name] = attr.value
        end

        # Add child elements recursively
        node.element_children.each do |child|
          result[child.name] ||= []
          result[child.name] << xml_to_hash(child)
        end

        # Add element's text content (if it exists)
        text_content = node.text.strip
        result['text'] = text_content unless text_content.empty?

        result
      end
    end
  end

```

### Step 3: Configure the Plugin in `_config.yml`

In your site's `_config.yml`, you need to specify the XML sources and the output filenames. Here's how to configure it:

```
xml_to_json:
  - url: 'http://example.com/feed.xml'
    output: 'example_feed'
```

You can specify as many sources as needed by adding more entries under `xml_to_json`.

### Step 4: Building Your Site

To build your site in the production environment (which will trigger the XML-to-JSON conversion), use:

```
JEKYLL_ENV=production bundle exec jekyll build
```

The plugin will then fetch the specified XML files, convert them into JSON, and save them in the `_data/` folder.

### Step 5: Accessing JSON Data in Your Jekyll Site

Once the JSON files are generated and stored in `_data`, you can access the data in your Liquid templates like this:

```
{% assign data = site.data.example_feed %}
<p>{{ data.root.text }}</p>
```

### Notes

-   The plugin will not run if `JEKYLL_ENV` is not set to `production`, ensuring local environments without the required gems won't be affected.
-   Ensure the URLs in your `_config.yml` are correct and accessible.

