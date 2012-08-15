pie.load ->

  class TipMessage
    request: ->
      jQuery.ajax
        url:'/check_tip_messages'
        dataType: 'json'
        success : (json)=>
          if json.comments_count > 0
            @show_tip_dialog(json)

    show_tip_dialog: (web_json)->
      @_set_attr('comment', web_json.comments_count)
      @_set_attr('media_share', web_json.media_shares_count)

    get_dialog: ->
      if !jQuery('.page-tip-message-dialog').exists()
        $comment = jQuery("<div></div>")
          .addClass('item comment')
          .append("<span></span>")
          .append("<a href='#{window.USER_INFO['paths']['comment']}'>查看评论</a>")
          .hide()

        $media_share = jQuery("<div></div>")
          .addClass('item media_share')
          .append("<span></span>")
          .append("<a href='#{window.USER_INFO['paths']['media_share']}'>点击查看</a>")
          .hide()

        @$dialog = jQuery("<div class='page-tip-message-dialog'></div>")
          .hide()
          .append($comment)
          .append($media_share)
          .appendTo jQuery(document.body)
      else
        @$dialog

    _set_attr: (kind, count)->
      @$dialog = @get_dialog()

      if ~~count == 0
        @$dialog.find(".#{kind}").addClass('zero').fadeOut(200)

        @$dialog.fadeOut() if @$dialog.find('.item.zero').length == @$dialog.find('.item').length
        return

      switch kind
        when 'comment'
          @$dialog
            .fadeIn()
            .find('.comment').removeClass('zero').fadeIn(200)
            .find('span').html("#{count}条新评论，")
        when 'media_share'
          @$dialog
            .fadeIn()
            .find('.media_share').removeClass('zero').fadeIn(200)
            .find('span').html("#{count}个新资源分享，")

    bind_juggernaut_listener: ->
      @jug = new Juggernaut

      @jug.subscribe window.USER_INFO['channels']['comment'], (json)=>
        # console.log(json)
        @change_tip_dialog('comment', json.count)

      @jug.subscribe window.USER_INFO['channels']['media_share'], (json)=>
        @change_tip_dialog('media_share', json.count)


    change_tip_dialog: (kind, count)->
      @$dialog = @get_dialog()
      @_set_attr(kind, count)

  if window.USER_INFO
    tip_message = new TipMessage()
    tip_message.request()
    tip_message.bind_juggernaut_listener()