module ApplicationHelper
  def bootstrap_class_for flash_type
    { success: "alert-success", error: "alert-danger", alert: "alert-warning", notice: "alert-info" }.stringify_keys[flash_type.to_s] || flash_type.to_s
  end

  def flash_messages(opts = {})
    flash.each do |msg_type, message|
      tag = concat(content_tag(:div, class: 'modal-body') do
				concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} alert-dismissable fade show", role: 'alert') do 
        	concat content_tag(:button, "<span aria-hidden='true'>×</span>".html_safe, type: 'button', 'aria-label' => 'close', class: 'close push-xs-right', data: { dismiss: 'alert' })
        	concat message
	      end)
			end)
    end
    nil
  end
end
