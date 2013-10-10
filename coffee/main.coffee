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

    TimerPerSecond:30

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

    THRESHOULD:200 #差分の閾値
    PERPIXEL:16

    # @params image CanvasのImageDataオブジェクト
    constructor: ->
        @target = []

    # @params image CanvasのImageDataオブジェクト
    setImage: (image)->
        @prevImage = @image || null
        @prevTarget = $.extend(true, {}, @target) || null

        @image = image
        @width = image.width
        @height = image.height

        @setTarget()

    getImage: ->
        @image

    #
    # 画像の中の対象とするピクセルをtargetとして保存する
    #
    setTarget: ->
        data = @image.data
        for x in [0..@width-1]
            @target[parseInt(x/@PERPIXEL)] ||= {}
            for y in [0..@height-1]
                # 対象pixelのindex（色情報があるので*@PERPIXELする)
                if x % @PERPIXEL == 0  and y % @PERPIXEL == 0
                    index = (x + y * @width) * 4
                    @target[parseInt(x/@PERPIXEL)][parseInt(y/@PERPIXEL)] = {}
                    @target[parseInt(x/@PERPIXEL)][parseInt(y/@PERPIXEL)][0] = data[index + 0]
                    @target[parseInt(x/@PERPIXEL)][parseInt(y/@PERPIXEL)][1] = data[index + 1]
                    @target[parseInt(x/@PERPIXEL)][parseInt(y/@PERPIXEL)][2] = data[index + 2]

    #
    # targetと1つ前のtargetを比較して差分をオブジェクトとして返す
    # @return diff[x][y]に差分の値が入る
    getDiff: ->
        if @prevTarget.length == 0
            return null
        diff = {}

        for x in [0..(@width/@PERPIXEL)-1]
            diff[x] ||= {}
            for y in [0..(@height/@PERPIXEL)-1]
                diff[x][y] = Math.abs(@target[x][y][0] - @prevTarget[x][y][0]) + Math.abs(@target[x][y][1] - @prevTarget[x][y][1]) + Math.abs(@target[x][y][2] - @prevTarget[x][y][2])
        return diff

    #
    # 差分を比較して異なっている部分を追加した画像を生成する
    #
    getProcessedImage:->
        #target pixelを差分比較
        diff = @getDiff()
        #閾値を超えるかどうか判別
        if diff
            #target pixelの支配する部分を塗りつぶす
            data = @image.data
            for x in [0..@width-1]
                for y in [0..@height-1]
                    # 対象pixelのindex（色情報があるので*@PERPIXELする）
                    if diff[parseInt(x/@PERPIXEL)][parseInt(y/@PERPIXEL)] >= @THRESHOULD
                        index = (x + y * @width) * 4
                        data[index + 0] = 0
                        data[index + 1] = 0
                        data[index + 2] = 0
                        data[index + 3] = 255
            @image.data = data
        return @image


    #
    # @params image CanvasのImageDataオブジェクト
    # @return image CanvasのImageDataオブジェクト
    #
    execute: (image)->
        @setImage(image)
        @getProcessedImage()


$ ->
    #videoオブジェクトを取得する
    video = $('#video')[0]
    canvas = $('#canvas')[0]

    #canvasコントローラーを起動
    canvasController = new App.CanvasController(video,canvas)
    canvasController.setEngine(new App.FlameDiffProcessingEngine())

    $('#start').click(-> canvasController.videoStart())
    $('#stop').click(-> canvasController.videoStop())



