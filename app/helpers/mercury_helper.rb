module MercuryHelper

  def mercury_edit_path(path = nil)
    mercury_engine.mercury_editor_path(path.nil? ? request.path.gsub(/^\/\/?(editor)?/, '') : path)
  end


  def render_region(region_name, region_type, attrs)
    # because we'll never know all the different things a region may need, we can't create a model+migration for each different region type.
    # instead, we will store ANY additional property in the attrs[] (except data-region_name and data-region_type as these get their own columns),
    # and then just render accordingly for each case.
    # READ: so that they all get saved, you'll need to edit the list in mercury.js (line ~235) by modifying Mercury.config.regions.saveAttributes[]

    # instantiate the region...
    region = @page.regions.where(:region_name => region_name).first_or_initialize(:region_name => region_name)
    if region.new_record?
      region.pages << @page
      region.region_type = region_type
      region.attrs = attrs
      region.snippets = {}
      region.value = ""
    else
      # if it wasn't a new record, but the attrs we passed in isn't the same as what was stored in the db
      # ex: someone added attributes/html attributes in the page (like a class or different data-attribute)
      # we assume the attrs we passed in take precedence
      if attrs != region.attrs
        region.attrs = attrs
      end
      # same for region_type
      if region_type != region.region_type
        region.region_type = region_type
      end
    end
    region.save

    # since region_name and region_type have their own specific columns on the region model, we don't store them in the attrs column in the db
    # (these have also been excluded from Mercury.config.saveAttributes[] in mercury.js so they do not get saved)
    # we do however still actually want them in the attrs[] so they get rendered and appear as html attributes in the DOM when the page is rendered
    # note that the reason we break convention and prefix these with region_ is because "name" is a normal html attribute, and "type" is a reserved mysql word
    region.attrs["data-region_name"] = region.region_name
    region.attrs["data-region_type"] = region.region_type

    # if this region has any snippets to render...
    if !region.snippets.nil? && region.snippets.any?
      # ex: looks for the string [snippet_4] in region.value, replaces it with the html that you receive back after rendering
      # /mercury/snippets/<snippet_4's name>/preview.html.erb with the snippets options hash (which is stored in region.snippets in the db)
      region.snippets.each do |snippet|
        old_html = "[" + snippet["id"] + "]"
        new_html = render(:file => "mercury/snippets/" + snippet["name"] + "/preview.html.erb", :locals => {:params => {:options => snippet["options"]}})
        region.value = region.value.sub(old_html, new_html)
      end
    end
    # render it!
    content_tag(:div, raw(region.value), region.attrs)
  end


  def render_snippet_region(region_name, accepted_snippets, number_of_snippets, attrs={})
    # here we get to add a bunch of stuff (namely html attributes) so we can use them to do stuff on the client side...
    attrs["data-number_of_snippets"] = number_of_snippets
    # data-accepted_snippets is a comma delimited string of snippets which we will allow to be dropped into this snippet region
    if attrs.has_key?("data-accepted_snippets")
      accepted_snippets.split(",").each do |name|
        attrs["data-accepted_snippets"] << "," + name if !attrs["data-accepted_snippets"].include?(name)
      end
    else
      attrs["data-accepted_snippets"] = accepted_snippets
    end
    # remove whitespace so string should look like "foo,bar,baz"
    attrs["data-accepted_snippets"] = attrs["data-accepted_snippets"].gsub(/\s+/, "")

    # render as a snippet region
    render_region(region_name, "snippets", attrs)
  end



  # there's 3 types of regions: full, simple, snippet....

  # full region is where you can do anything
  def full_region(region_name, attrs={})
    attrs["data-accepted_snippets"] = "image"
    attrs["data-number_of_snippets"] = 99
    render_region(region_name, "full", attrs)
  end

  # simple region is where you can only edit text (no snippets or styles)
  def simple_region(region_name, attrs={})
    render_region(region_name, "simple", attrs)
  end

  # markdown region is where you can enter github-flavored markdown syntax
  # def markdown_region(region_name, attrs={}, snippets = {}, value="")
    # region(region_name, "markdown", attrs, snippets, value)
  # end

  # snippet region is where you can only add snippets
  # snippets...
  def any_snippet_region(region_name, attrs={})
    render_snippet_region(region_name, "*", 99, attrs)
  end

  def image_snippet_region(region_name, attrs={})
    render_snippet_region(region_name, "image", 1, attrs)
  end

end
