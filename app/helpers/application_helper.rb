module ApplicationHelper

  def form_errors(obj, field=nil)
    if field
      obj.errors.messages[field]
        .collect { |msg| "<p class=\"fld-error\">#{msg}</p>" }
        .join(' ').html_safe
    elsif obj.errors.messages.length > 0
      "Unable to save - #{obj.errors.messages.length} fields with errors: (" +
        obj.errors.messages.keys.join(', ') + ")"
    end
  end

end
