Rails.application.config.after_initialize do

  AspaceFormHelper.class_eval do

    PROPERTIES_TO_EXCLUDE_FROM_READ_ONLY_VIEW = ["jsonmodel_type", "lock_version", "_resolved", "uri", "ref", "create_time", "system_mtime", "user_mtime", "created_by", "last_modified_by", "sort_name_auto_generate", "suppressed", "display_string", "file_uri"]

    # This is a copy of read_only_view in the AspaceFormHelper
    # The only significant difference is that it adds a 'for' attribute to
    # the control-label so that the js can tell which field it belongs to
    # cut and paste coding - sorry, bad
    def awesomer_read_only_view(hash, opts = {})
      jsonmodel_type = hash["jsonmodel_type"]
      schema = JSONModel(jsonmodel_type).schema
      prefix = opts[:plugin] ? 'plugins.' : ''
      html = "<div class='form-horizontal'>"

      hash.reject {|k,v| PROPERTIES_TO_EXCLUDE_FROM_READ_ONLY_VIEW.include?(k)}.each do |property, value|

        if schema and schema["properties"].has_key?(property)
          if (schema["properties"][property].has_key?('dynamic_enum'))
            value = I18n.t("#{prefix}enumerations.#{schema["properties"][property]["dynamic_enum"]}.#{value}", :default => value)
          elsif schema["properties"][property].has_key?("enum")
            value = I18n.t("#{prefix}#{jsonmodel_type.to_s}.#{property}_#{value}", :default => value)
          elsif schema["properties"][property]["type"] === "boolean"
            value = value === true ? "True" : "False"
          elsif schema["properties"][property]["type"] === "date"
            value = value.blank? ? "" : Date.strptime(value, "%Y-%m-%d")
          elsif schema["properties"][property]["type"] === "array"
            # this view doesn't support arrays
            next
          elsif value.kind_of? Hash
            # can't display an object either
            next
          end
        end

        html << "<div class='form-group'>"
        html << "<div class='control-label col-sm-2' for='#{opts['parent']}_#{jsonmodel_type.to_s}__#{property}_'>#{I18n.t("#{prefix}#{jsonmodel_type.to_s}.#{property}")}</div>"
        html << "<div class='label-only col-md-9'>#{value}</div>"
        html << "</div>"

      end

      html << "</div>"

      html.html_safe
    end

  end

end