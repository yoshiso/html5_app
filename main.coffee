$ ->
    window.App = 
        CanvasController: {}
        ImageProcessingEngine: {}
        FlameDiffProcessingEngine: {}

    #
    # video DOMオブジェクトをcanvasに描画して操作するためのクラス
    # @params video video DOMオブジェクト
    # @params canvas canvasDOMオブジェクト
    #
    class App.CanvasController

        TimerPerSecond:400

        constructor:(@video, @canvas) ->
            @checkMedia()

            #ブラウザごとの違いを共通化
            navigator.getUserMedia = navigator.webkitGetUserMedia || navigator.getUserMedia
            window.URL = window.URL || window.webkitURL

            @ctx = @canvas.getContext('2d')

            navigator.getUserMedia(
                {video: true}
                (stream) =>
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
            @timer = setInterval(@renderCanvas,@TimerPerSecond)

        videoStop: ->
            @localMediaStream.stop()
            clearInterval(@timer)

        getImageData: ->
            #現在のImageDataオブジェクトを取得する
            @ctx.getImageData(0,0,@video.videoWidth,@video.videoHeight)

        renderCanvas: =>
            @canvas.height = @video.videoHeight
            @canvas.width = @video.videoWidth
            @ctx.drawImage(@video, 0, 0)
            @ctx.putImageData(@getProcessedImage(),0 ,0)

        checkMedia: ->
            #WebRTCAPIが使えるかどうかをチェックする
            if @hasGetUserMedia()
                console.log('カメラOk')
            else
                alert('カメラが使用できません')

        setEngine: (@imageEngine) ->

        getProcessedImage: ->
            @imageEngine.execute(@getImageData())

    class App.ImageProcessingEngine

        constructor:(image)->
            @width = image.width
            @height = image.height
            @imageData = image.data

        execute: ->
            #console.log(@imageData)
            console.log('ok')

    class App.FlameDiffProcessingEngine

        # @params image CanvasのImageDataオブジェクト
        constructor: ->

        # @params image CanvasのImageDataオブジェクト
        setImage: (image)->
            @prevImage = @image || null
            @image = image
            @width = image.width
            @height = image.height


        getImage: ->
            @image

        #
        # @return ImageDataのdataオブジェクト(r,g,b,a)の配列
        #
        getDiff: ->
            #2つの画像の差分をLookupテーブルに出力(0 or 1)
            if not @prevImage
                return null
            data = @image.data
            prev = @prevImage.data
            diff = []
            for x in [0..@width]
                for y in [0..@height]
                    # 対象pixelのindex（色情報があるので*4する） 
                    index = (x + y * @width) * 4;
                    diff[index + 0] = data[index+0] - prev[index+0];
                    diff[index + 0] = 0 - diff[index + 0] if diff[index + 0] < 0
                    diff[index + 1] = data[index+1] - prev[index+1];
                    diff[index + 1] = 0 - diff[index + 1] if diff[index + 1] < 0
                    diff[index + 2] = data[index+2] - prev[index+2];
                    diff[index + 2] = 0 - diff[index + 2] if diff[index + 2] < 0
            return diff

        getProcessedImage:->
            diff = @getDiff()
            console.log(diff)
            #画像を処理
            before_image = @image
            data = before_image.data
            for x in [0..@width]
                for y in [0..@height]
                    index = (x + y * @width) * 4;
                    if diff and diff[index + 0] > 50 and diff[index + 1] > 50 and diff[index + 2] > 50
                        # 対象pixelのindex（色情報があるので*4する） 
                        data[index + 0] = 0;
                        data[index + 1] = 0;
                        data[index + 2] = 0;
                        data[index + 3] = 255;
            before_image.data = data
            return before_image


        #
        # @params image CanvasのImageDataオブジェクト
        # @return image CanvasのImageDataオブジェクト
        #
        execute: (image)->
            @setImage(image)
            @getProcessedImage()


    #videoオブジェクトを取得する
    video = $('#video')[0]
    canvas = $('#canvas')[0]

    #canvasコントローラーを起動
    canvasController = new App.CanvasController(video,canvas)
    canvasController.setEngine(new App.FlameDiffProcessingEngine())

    $('#start').click(-> canvasController.videoStart())
    $('#stop').click(-> canvasController.videoStop())

    


