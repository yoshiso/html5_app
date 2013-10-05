$ ->

    #関数群

    #WebRTCVideoが使えるかどうかを判定する
    hasGetUserMedia=->
        return !!(navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia)

    #videoオブジェクトを取得する
    video = $('#video')[0]
    canvas = $('#canvas')[0]
    ctx = canvas.getContext('2d')

    #共通化
    navigator.getUserMedia = navigator.webkitGetUserMedia || navigator.getUserMedia
    window.URL = window.URL || window.webkitURL

    #処理開始
    if hasGetUserMedia()
        console.log('カメラOk')
    else
        alert('カメラが使用できません')

    navigator.getUserMedia(
        {video: true}
        (stream) ->
            localMediaStream = stream;
            video.src = window.URL.createObjectURL(localMediaStream);
            video.play()
            setInterval(render,100)
        (err) ->
            alert('error')
            console.log(err)
    );

    render=->
        console.log('rendered')
        canvas.height = video.videoHeight
        canvas.width = video.videoWidth
        ctx.drawImage(video, 0, 0)

    


