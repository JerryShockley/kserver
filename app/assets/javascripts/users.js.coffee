jQuery ->
  $('form').on 'click', '.remove_sort_fields', (event) ->
    sort_count = $('.sort_row').length
    sort_count--
    if (sort_count == 0)
      $("#q_s_0_name").val("")
      $("#q_s_0_dir").val("asc")
    else
      sort_count -= 1
      $(this).closest('.field').remove()
    event.preventDefault()
  
  $('form').on 'click', '.remove_condition_fields', (event) ->
    condition_count = $('.condition_row').length
    condition_count--
    if (condition_count == 0)
      $("#q_c_0_a_0_name").val("")
      $("#q_c_0_p").val("cont")
      $("#q_c_0_v_0_value").val("")
    else
      condition_count -= 1
      $(this).closest('.field').remove()
    event.preventDefault()
      

  $('form').on 'click', '.add_sort_fields', (event) ->
    search_count = $('.sort_row').length
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, search_count++))
    event.preventDefault()
    


  $('form').on 'click', '.add_condition_fields', (event) ->
    search_count = $('.condition_row').length
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, search_count++))
    event.preventDefault()

  if $('.pagination').length
    $(window).scroll ->
      url = $('.pagination .next_page').attr('href')
      if url && $(window).scrollTop() > $(document).height() - $(window).height() - 50
        $('.pagination').text("Fetching more products...")
        $.getScript(url)
    $(window).scroll()