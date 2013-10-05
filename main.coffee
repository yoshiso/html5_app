$ ->

    #
    # video DOMオブジェクトをcanvasに描画して操作するためのクラス
    # @params video video DOMオブジェクト
    # @params canvas canvasDOMオブジェクト
    #
    class CanvasController

        constructor:(@video, @canvas) ->
            @checkMedia()

            #ブラウザごとの違いを共通化
            navigator.getUserMedia = navigator.webkitGetUserMedia || navigator.getUserMedia
            window.URL = window.URL || window.webkitURL

            @ctx = @canvas.getContext('2d')

            navigator.getUserMedia(
                {video: true}
                (stream) ->
                    @localMediaStream = stream;
                    @video.src = window.URL.createObjectURL(@localMediaStream);
                (err) ->
                    alert('error')
                    console.log(err)
            );

        hasGetUserMedia: ->
            #WebRTCVideoが使えるかどうかを判定する
            return !!(navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia)

        videoStart: ->
            @video.play()
            @timer = setInterval(@renderCanvas,100)

        videoStop: ->
            @localMediaStream.stop
            clearInterval(@timer)

        getImageData: ->
            @ctx.getImageData(0,0,@video.videoWidth,@video.videoHeight)

        renderCanvas: =>
            @canvas.height = @video.videoHeight
            @canvas.width = @video.videoWidth
            @ctx.drawImage(@video, 0, 0)

        checkMedia: ->
            #WebRTCAPIが使えるかどうかをチェックする
            if @hasGetUserMedia()
                console.log('カメラOk')
            else
                alert('カメラが使用できません')

    class ImageProcessingEngine

        constructor:->


    window.CanvasController = CanvasController
    #videoオブジェクトを取得する
    video = $('#video')[0]
    canvas = $('#canvas')[0]

    canvasController = new CanvasController(video,canvas)
    canvasController.videoStart()



    


