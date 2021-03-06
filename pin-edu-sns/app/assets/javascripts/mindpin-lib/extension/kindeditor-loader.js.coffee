try

  items = [
          'source', '|', 'undo', 'redo', '|', 'preview', 'template', 'cut', 'copy', 'paste',
          'plainpaste', 'wordpaste', '|', 'justifyleft', 'justifycenter', 'justifyright',
          'justifyfull', 'insertorderedlist', 'insertunorderedlist', 'indent', 'outdent', 'subscript',
          'superscript', 'clearhtml', 'quickformat', 'selectall', '|', 'fullscreen', '/',
          'formatblock', 'fontname', 'fontsize', '|', 'forecolor', 'hilitecolor', 'bold',
          'italic', 'underline', 'strikethrough', 'lineheight', 'removeformat', '|', 'image', 'multiimage',
          'insertfile', 'table', 'hr', 'emoticons',
          'link', 'unlink', '|', 'about'
  ]

  KindEditor.ready (K) ->
    jQuery('.kind-editor').each ->
      $ele = jQuery(this)
      width = $ele.data('width') || '650px'
      height = $ele.data('height') || '350px'

      editor = K.create $ele,
        uploadJson : "/kindeditor_upload"
        items      : items
        width : width
        height : height

      jQuery(document).on 'form-ready-submit', ->
        try
          editor.sync()
        catch e
catch e
